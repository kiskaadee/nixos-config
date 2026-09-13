# 🚀 Getting Started & Disaster Recovery

This document is the operational procedure for bootstrapping the workstation host (`laptop`) from bare metal or recovering after a catastrophic drive failure.

---

## 1. Prerequisites & Installation Media

1. Download the latest official NixOS Minimal ISO from [nixos.org](https://nixos.org/download.html).
2. Flash the ISO to a USB flash drive:
   ```bash
   sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
3. Boot the laptop from the USB drive in UEFI mode.

---

## 2. Disk Partitioning & Mounting

Assuming NVMe target drive `/dev/nvme0n1`:

```bash
# 1. Create GPT partition table
parted /dev/nvme0n1 -- mklabel gpt

# 2. EFI System Partition (1GB, FAT32)
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1024MiB
parted /dev/nvme0n1 -- set 1 esp on

# 3. Root Partition (remaining space, Ext4 or Btrfs)
parted /dev/nvme0n1 -- mkpart primary ext4 1024MiB 100%

# 4. Format filesystems
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2

# 5. Mount targets for installation
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

---

## 3. Clone Repository & Hardware Detection

```bash
# Generate hardware configuration scan into a temporary directory
nixos-generate-config --root /mnt

# Clone the declarative workstation configuration
git clone https://github.com/kiskaadee/Config.git /mnt/etc/nixos

# Replace the repository hardware configuration with the generated one
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/system/hardware-configuration.nix
```

> [!IMPORTANT]
> Verify that the filesystem UUIDs in `system/hardware-configuration.nix` match the output of `blkid /dev/nvme0n1p*`.

---

## 4. Install & Initial System Build

```bash
# Enable flakes on the installer shell
export NIX_CONFIG="experimental-features = nix-command flakes"

# Perform initial system installation using the laptop target
nixos-install --flake /mnt/etc/nixos#laptop

# Set root and user passwords when prompted, then reboot:
reboot
```

---

## 5. First Graphical Login & Desktop Bootstrap

1. Remove the USB flash drive and boot into the installed system.
2. At the `dank-greeter` display manager screen, log in as `kiskaadee`.
3. Open a terminal (`Mod+Return`).

### Desktop Initialization Phase
On a fresh machine, DMS requires a one-time setup command to seed its mutable baseline keybindings:

```bash
dms setup binds
```

This generates `~/.config/niri/dms/binds.kdl` with standard user write permissions (`0644`). From this point forward:
- Niri loads all standard DMS IPC shortcuts (`Mod+Space` for spotlight launcher, `Mod+V` for clipboard, `Mod+M` for task manager, `Super+X` for power menu, volume and brightness controls).
- DMS owns, updates, and mutates `~/.config/niri/dms/` and `~/.config/DankMaterialShell/settings.json` without conflicting with the declarative Nix store.

---

## 6. Operator Secrets Bootstrap (Access to Core)

The workstation acts as the administrative cockpit for the homelab. To enable editing and rotating secrets in `Core`:

1. Restore your personal `age` secret key from a secure backup (e.g. Bitwarden or offline medium) into:
   ```bash
   mkdir -p ~/.config/sops/age
   chmod 700 ~/.config/sops/age
   # Place your private key in:
   # ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```
2. Verify operator decryption capability:
   ```bash
   cd ~/Projects/active/homelab/Core/nixos
   sops secrets.yaml
   ```

---

## 7. Verification Checklist

| Check | Command | Expected Outcome |
| :--- | :--- | :--- |
| Flake Validation | `nix flake check` | Evaluates with zero errors. |
| Dry Build | `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link` | Builds cleanly. |
| Compositor Status | `niri msg version` | Reports running Niri version. |
| DMS Shell Daemon | `systemctl --user status dms.service` | Active (running). |
| Desktop Search | `systemctl --user status dsearch.service` | Active (running) on port 43654. |
