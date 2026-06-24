import urllib.request
import re
import json
import os
import subprocess
import sys
from datetime import datetime

HISTORY_FILE = os.environ.get("HISTORY_FILE", "/var/lib/dynu/ip_history.jsonl")
PROVIDERS = [
    "https://api.ipify.org",
    "https://ifconfig.me/ip",
    "https://icanhazip.com",
    "https://wtfismyip.com/text"
]


def is_valid_public_ipv4(ip):
    match = re.match(r"^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$", ip)
    if not match:
        return False
    octets = [int(x) for x in match.groups()]
    if any(x > 255 for x in octets):
        return False
    a, b, c, d = octets
    # Exclude private/reserved IP blocks
    if a == 10:
        return False
    if a == 192 and b == 168:
        return False
    if a == 172 and 16 <= b <= 31:
        return False
    if a == 100 and 64 <= b <= 127:
        return False
    if a == 127:
        return False
    if a == 169 and b == 254:
        return False
    return True


def get_public_ip():
    errors = []
    for provider in PROVIDERS:
        try:
            req = urllib.request.Request(
                provider,
                headers={
                    'User-Agent': 'Mozilla/5.0'
                }
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                ip = response.read().decode('utf-8').strip()
                if is_valid_public_ipv4(ip):
                    return ip
                else:
                    errors.append(f"{provider}: invalid public IPv4 '{ip}'")
        except Exception as e:
            errors.append(f"{provider}: {str(e)}")
    print(
        f"Error: All IP discovery providers failed. Details: {errors}",
        file=sys.stderr
    )
    return None


def get_last_recorded_ip():
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
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
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
    current_ip = get_public_ip()
    if not current_ip:
        sys.exit(1)

    last_ip = get_last_recorded_ip()
    if current_ip == last_ip:
        # IP matches the last recorded working IP; do nothing
        sys.exit(0)

    print(f"IP rotation detected! Old: {last_ip}, New: {current_ip}")

    success, error_msg = trigger_ddclient()
    if success:
        print("Dynu DDNS update via ddclient triggered successfully.")
        record_ip(current_ip, "success")
    else:
        err_msg = f"Error: Failed to trigger ddclient update: {error_msg}"
        print(err_msg, file=sys.stderr)
        record_ip(current_ip, "failed_update", details=error_msg)
        sys.exit(1)


if __name__ == "__main__":
    main()
