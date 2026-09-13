# ⚙️ Configuration & Dotfiles Workflow

This guide details the day-to-day workflow for modifying system declarations, managing user dotfiles, and safely testing changes without destabilizing the workstation.

---

## 1. The Standard Modification Protocol

To preserve system reliability and adhere to the architectural invariants:

```text
Identify Concern
       ↓
Find Owning Module (system/ or home/)
       ↓
Edit Declaration
       ↓
Run Flake Check: nix flake check
       ↓
Run Dry Build: nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link
       ↓
Test Activation: sudo nixos-rebuild test --flake .#laptop
       ↓
Permanent Switch: sudo nixos-rebuild switch --flake .#laptop
       ↓
Commit Changes: git commit -am "feat: ..."
```

---

## 2. The Golden Rule: Build, Never Switch

> [!CAUTION]
> Autonomous agents and automated scripts must **never** execute `nixos-rebuild switch` autonomously. Only human operators may execute switch or boot operations.

### Verification Commands (Safe)
```bash
# Check flake schema, lock consistency, and syntax
nix flake check

# Dry build laptop system closure without creating links or modifying root
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link
```

### Activation Commands (Privileged)
```bash
# Test configuration in the active session without updating the bootloader menu
sudo nixos-rebuild test --flake .#laptop

# Permanently activate and add a new generation to systemd-boot menu
sudo nixos-rebuild switch --flake .#laptop
```

---

## 3. Dotfiles Management Strategy

Dotfiles in this repository are managed through two distinct patterns:

### Pattern A: Immutable Store Symlinks (`home.file` / `xdg.configFile`)
Used for applications whose configuration is purely declarative and must never be mutated at runtime by the application:

```nix
# Example in home/desktop.nix
home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;
home.file.".config/niri/custom.kdl".source = ./config/niri/custom.kdl;
home.file.".config/zed/settings.json".source = ./config/zed/settings.json;
```

- Target location in `$HOME` is a symlink pointing into `/nix/store/...`.
- If you edit the file in `home/config/`, rebuild the system to update the symlink target.

### Pattern B: Runtime Mutable Configurations (DMS & Browser State)
Used for tools that provide their own GUI settings editor or dynamic state:

- `~/.config/DankMaterialShell/settings.json`
- `~/.config/niri/dms/*.kdl`
- Firefox / Zen profiles, history, and extensions

These directories are **deliberately unmanaged by Home Manager**. They are modified interactively through their respective applications without interference from `nixos-rebuild switch`.

---

## 4. Git Hygiene & Pre-Commit Checks

1. Verify status before committing:
   ```bash
   git status
   ```
2. Ensure no decrypted credentials, age private keys, or `.env` files are tracked:
   ```bash
   git diff
   ```
3. Commit with Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`).
