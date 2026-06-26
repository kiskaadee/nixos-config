# 🛠️ System Maintenance Guide

This document describes how to update the system safely, verify its health post-update, and clean up disk space by removing old configurations.

---

## 🔄 Performing Clean & Secure System Updates

NixOS systems managed with Flakes lock dependency versions inside `flake.lock`. To update the system securely, follow this workflow:

### Step 1: Update the Flake Inputs
Fetch the latest revisions of your inputs (e.g., `nixpkgs`, `home-manager`, and other plugins):
```bash
nix flake update
```

### Step 2: Validate the Build & Formatting
Test-build the derivation without applying it to your bootloader. This prevents dirty installations or builder failures (such as Python PEP8 style errors) from affecting system configuration state:
```bash
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link
```

### Step 3: Switch & Apply the Update
Once the test build completes successfully, switch to the new generation:
```bash
sudo nixos-rebuild switch --flake .#desktop
```

---

## 🏥 Post-Update Health Checklist

Verify system health immediately after a major system switch:

1.  **Systemd Service Status:** Ensure all units are running and no critical services failed:
    ```bash
    systemctl --failed
    systemctl --user --failed
    ```
2.  **Display & Window Manager:** Verify that your graphics drivers, audio services (PipeWire/WirePlumber), and hotkeys are responsive.
3.  **Secrets Integrity:** Check that decrypted secrets are loaded correctly:
    ```bash
    ls -la /run/secrets/
    ```
4.  **Network Resolution:** Check DNS resolution and active IP rotation daemons:
    ```bash
    systemctl status dynu-monitor.service
    ```

---

## 🧹 Cleaning Up Old Generations

Nix keeps older versions (generations) of your system configuration so you can roll back instantly. However, this takes up storage space.

### Step 1: List System Generations
To view all available system generations:
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Step 2: Delete Old Generations
*   **Remove older than X days:**
    ```bash
    sudo nix-env --delete-generations +5d --profile /nix/var/nix/profiles/system
    ```
*   **Remove specific generations:**
    ```bash
    sudo nix-env --delete-generations 42 43 --profile /nix/var/nix/profiles/system
    ```

### Step 3: Collect Garbage (Reclaim Disk Space)
Deleting generations only updates configuration links. To actually free up disk space and prune unused dependencies:
```bash
# Run garbage collection for system and user profiles
sudo nix-collect-garbage -d
nix-collect-garbage -d
```
