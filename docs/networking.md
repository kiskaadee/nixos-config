# 🌐 Workstation Networking & Remote Access

This document details network management, OpenSSH client infrastructure, and remote workstation accessibility.

---

## 1. Local Network Stack: NetworkManager

The workstation manages network interfaces, Wi-Fi connections, and DNS via **NetworkManager** declared in `system/core.nix`:

```nix
networking = {
  hostName = "laptop";
  networkmanager.enable = true;
};
```

### Essential CLI Operations
```bash
# Scan available Wi-Fi networks
nmcli dev wifi list

# Connect to a Wi-Fi network
nmcli dev wifi connect "SSID_NAME" password "PASSPHRASE"

# Check active connections
nmcli con show --active

# Monitor network device status
nmcli device status
```

---

## 2. Workstation Remote Access: OpenSSH Daemon

Local SSH access is enabled in `system/core.nix` with strict security defaults:

```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };
};
```

> [!NOTE]
> The local OpenSSH daemon is an interactive workstation tool (for remote terminal sessions, LAN editor attachments, and file transfers). It is **not** server infrastructure.

---

## 3. SSH Client Profiles & Homelab Ingress

SSH client connections are declaratively managed by Home Manager in `home/shell.nix`.

### Defined Host Blocks
| Host Alias | Destination | Port | Use Case |
| :--- | :--- | :--- | :--- |
| **`server-local`** | `192.168.1.200` | 22 | High-speed LAN access to the 24/7 homelab host. |
| **`server-remote`** | `server.roadtotech.me` | 2222 | Remote WAN access through the external edge firewall. |
| **`gitea.roadtotech.me`** | `server.roadtotech.me` | 2223 | Git SSH operations for self-hosted repositories. |

### Connecting to the Homelab Host
```bash
# On home Wi-Fi (direct LAN connection):
ssh server-local

# Outside home (remote connection):
ssh server-remote
```

---

## 4. Bluetooth & Peripheral Networking

Bluetooth hardware support and audio integration are managed in `system/hardware.nix`:

```bash
# Open interactive Bluetooth controller
bluetoothctl

# Common pairing sequence:
# power on
# scan on
# pair <MAC>
# connect <MAC>
# trust <MAC>
```
