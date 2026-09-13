# 🔄 System Lifecycle: Rebuilding, Rollbacks & Maintenance

This document explains the technical lifecycle of the workstation—from Nix flake evaluation down to system activation—and provides operational procedures for rollbacks and disk maintenance.

---

## 1. What Happens During `nixos-rebuild switch`?

When you execute a system rebuild, NixOS and Home Manager execute a multi-stage pipeline:

```mermaid
graph TD
    FLAKE["flake.nix<br/><i>(Declarations & Pinned Inputs)</i>"] -->|Evaluate| DRV["Derivation Computation<br/><i>(/nix/store/*.drv)</i>"]
    DRV -->|Compile & Link| CLOSURE["System Closure<br/><i>(/nix/store/nixos-system-laptop-...)</i>"]
    
    subgraph Activation Phase ["System Activation (Root / Switch)"]
        CLOSURE --> SYS_PROFILE["Update /nix/var/nix/profiles/system"]
        SYS_PROFILE --> BOOT_LINK["Install to /boot/EFI/systemd-boot"]
        SYS_PROFILE --> SYSD_UNITS["Restart & Reload Modified systemd Services"]
        SYS_PROFILE --> PAM_USERS["Sync Users, Groups, and PAM Policies"]
    end

    subgraph Home Manager Phase ["User Session Activation"]
        CLOSURE --> HM_PROFILE["Update ~/.local/state/nix/profiles/home-manager"]
        HM_PROFILE --> SYMLINKS["Update ~/.config and ~/ Symlink Farm"]
        HM_PROFILE --> HM_UNITS["Restart systemd --user Units (e.g., dsearch, dms)"]
    end
```

---

## 2. The Command Matrix: Rebuild Actions

| Command | Rebuilds System? | Boots Next Time? | Affects Active Session? | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link` | Yes (Dry) | No | No | Safe validation of compilation without system mutation. |
| `sudo nixos-rebuild dry-build --flake .#laptop` | Yes (Dry) | No | No | Prints what would be built or downloaded. |
| `sudo nixos-rebuild test --flake .#laptop` | Yes (Live) | No | **Yes** | Test services or configs immediately without polluting bootloader. |
| `sudo nixos-rebuild switch --flake .#laptop` | Yes (Live) | **Yes** | **Yes** | Standard activation. Sets new default boot generation. |
| `sudo nixos-rebuild boot --flake .#laptop` | Yes (Live) | **Yes** | No | Prepares next boot without altering currently running services. |

---

## 3. Generations & Rollback Strategies

Every time `nixos-rebuild switch` runs, NixOS records a numbered generation.

### Strategy A: Bootloader Menu Rollback (Disaster Recovery)
If a new generation prevents the display server or network from starting:
1. Reboot the laptop.
2. At the `systemd-boot` menu, press `Space` or arrow keys.
3. Select an earlier generation from the list (e.g. `Generation 42`).
4. Boot into the known working system.

### Strategy B: Command-Line Rollback (Active Session)
If an update introduced a minor defect and you are logged in:
```bash
# Roll back system to the previous generation
sudo nixos-rebuild --rollback switch

# Roll back only Home Manager (user session)
home-manager generations
# Select generation ID to activate
```

### Strategy C: List Generations
```bash
# List system generations
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

---

## 4. Workstation Maintenance Runbook

### Routine Disk Cleanup
Over time, old generations accumulate in `/nix/store`:

```bash
# 1. Delete system generations older than 14 days
sudo nix-collect-garbage --delete-older-than 14d

# 2. Delete user-level generations older than 14 days
nix-collect-garbage --delete-older-than 14d

# 3. Clean untracked bootloader entries
sudo nixos-rebuild boot --flake .#laptop
```

### Updating Flake Dependencies
```bash
# Update all inputs (including nixpkgs channel tarball)
nix flake update

# Verify build before committing flake.lock
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link
```
