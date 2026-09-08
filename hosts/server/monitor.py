"""
Dynu DDNS Smart IP Change Monitor and Updater.

This script determines the current public IPv4 address by querying multiple
external resolvers in a stateful round-robin rotation. It compares the
discovered IP against the last recorded successful IP. If a change is
detected, it triggers `ddclient.service` on-demand to perform the DNS record
update.

This local-first state verification prevents making redundant API requests to
the DNS provider, avoiding rate-limiting, IP bans, or API abuse flags while
allowing frequent polling intervals (e.g. every 30 seconds).
"""

import json
import os
import re
import subprocess
import sys
import urllib.request
from datetime import datetime, timezone

# History and state file locations managed securely by the systemd service.
HISTORY_FILE = os.environ.get(
    "HISTORY_FILE", "/var/lib/dynu/ip_history.jsonl"
)
STATE_FILE = os.environ.get(
    "STATE_FILE", "/var/lib/dynu/state.json"
)

# Pool of reputable external resolvers to discover the public WAN IP.
PROVIDERS = [
    "https://api.ipify.org",
    "https://icanhazip.com",
    "https://ifconfig.me/ip",
    "https://checkip.dynu.com",
    "https://wtfismyip.com/text"
]


def extract_public_ipv4(text):
    """
    Extracts and validates the first valid public IPv4 address in text.

    This function excludes standard private, loopback, link-local, and CGNAT
    blocks to avoid recording temporary, local, or invalid network states.
    """
    match = re.search(r"\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b", text)
    if not match:
        return None
    octets = [int(x) for x in match.groups()]
    if any(x > 255 for x in octets):
        return None
    a, b, c, d = octets

    # RFC 1918 Private ranges: 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12
    if a == 10:
        return None
    if a == 192 and b == 168:
        return None
    if a == 172 and 16 <= b <= 31:
        return None

    # Carrier-Grade NAT (CGNAT) RFC 6598: 100.64.0.0/10
    if a == 100 and 64 <= b <= 127:
        return None

    # Loopback address range: 127.0.0.0/8
    if a == 127:
        return None

    # Link-local addresses: 169.254.0.0/16
    if a == 169 and b == 254:
        return None

    return ".".join(str(x) for x in octets)


def load_state():
    """
    Loads runtime state (last provider index and last verified IP).
    """
    if not os.path.exists(STATE_FILE):
        return {"last_provider_index": -1, "last_ip": None}
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"Warning: Failed to read state file: {e}", file=sys.stderr)
        return {"last_provider_index": -1, "last_ip": None}


def save_state(state):
    """
    Persists runtime state atomically to disk.
    """
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    tmp_path = f"{STATE_FILE}.tmp"
    try:
        with open(tmp_path, "w") as f:
            json.dump(state, f, indent=2)
        os.replace(tmp_path, STATE_FILE)
    except Exception as e:
        print(f"Error: Failed to write to state file: {e}", file=sys.stderr)


def get_public_ip(start_index=0):
    """
    Queries public IP providers in circular sequence starting from start_index.

    Returns:
        tuple: (validated_ip_string, successful_idx) or (None, None).
    """
    errors = []
    num_providers = len(PROVIDERS)
    for i in range(num_providers):
        idx = (start_index + i) % num_providers
        provider = PROVIDERS[idx]
        try:
            req = urllib.request.Request(
                provider,
                headers={
                    'User-Agent': 'Mozilla/5.0 (NixOS WAN Monitor)'
                }
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                raw_text = response.read().decode(
                    'utf-8', errors='replace'
                ).strip()
                ip = extract_public_ipv4(raw_text)
                if ip:
                    return ip, idx
                else:
                    snippet = raw_text[:50]
                    errors.append(
                        f"{provider}: no valid public IPv4 in '{snippet}'"
                    )
        except Exception as e:
            errors.append(f"{provider}: {e!s}")

    print(
        f"Error: All IP discovery providers failed. Details: {errors}",
        file=sys.stderr
    )
    return None, None


def get_last_recorded_ip_from_history():
    """
    Reads the history log to locate the last successful IP address.

    Returns:
        str: The last successfully updated IP, or None if no log exists yet.
    """
    if not os.path.exists(HISTORY_FILE):
        return None
    try:
        with open(HISTORY_FILE, "r") as f:
            lines = f.readlines()
            if not lines:
                return None
            for line in reversed(lines):
                try:
                    entry = json.loads(line)
                    if entry.get("status") == "success":
                        return entry.get("ip")
                except json.JSONDecodeError:
                    continue
    except Exception as e:
        print(f"Warning: Failed to read history file: {e}", file=sys.stderr)
    return None


def record_ip(ip, status, details=None):
    """
    Appends a new event entry into the JSONLines history registry.
    """
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "ip": ip,
        "status": status
    }
    if details:
        entry["details"] = details
    try:
        with open(HISTORY_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception as e:
        print(f"Error: Failed to write to history file: {e}", file=sys.stderr)


def trigger_ddclient():
    """
    Invokes the systemd service unit for `ddclient` on-demand.

    Returns:
        tuple: (bool, str) representing (success_boolean, error_details_string)
    """
    try:
        res = subprocess.run(
            ["systemctl", "start", "ddclient.service"],
            capture_output=True,
            text=True
        )
        if res.returncode == 0:
            return True, None
        else:
            err_msg = (
                f"systemctl exited with {res.returncode}: "
                f"{res.stderr.strip()}"
            )
            return False, err_msg
    except Exception as e:
        return False, str(e)


def main():
    """
    Orchestrator logic for DDNS state management with provider rotation.
    """
    state = load_state()
    last_provider_idx = state.get("last_provider_index", -1)
    next_provider_idx = (last_provider_idx + 1) % len(PROVIDERS)

    current_ip, successful_idx = get_public_ip(start_index=next_provider_idx)
    if not current_ip:
        sys.exit(1)

    state["last_provider_index"] = successful_idx

    last_ip = state.get("last_ip") or get_last_recorded_ip_from_history()
    if current_ip == last_ip:
        # State matches; save provider rotation state and exit cleanly
        save_state(state)
        sys.exit(0)

    provider_name = PROVIDERS[successful_idx]
    print(
        f"IP rotation detected! Old: {last_ip}, New: {current_ip} "
        f"(via {provider_name})"
    )

    # Trigger ddclient to perform the DNS record update
    success, error_msg = trigger_ddclient()
    if success:
        print("Dynu DDNS update via ddclient triggered successfully.")
        state["last_ip"] = current_ip
        save_state(state)
        record_ip(
            current_ip,
            "success",
            details=f"Provider: {provider_name}"
        )
    else:
        err_msg = f"Error: Failed to trigger ddclient update: {error_msg}"
        print(err_msg, file=sys.stderr)
        save_state(state)
        record_ip(current_ip, "failed_update", details=error_msg)
        sys.exit(1)


if __name__ == "__main__":
    main()
