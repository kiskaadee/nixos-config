# 📦 Package & Secrets Workflow Guide

This guide covers the day-to-day workflow for managing user-space packages and sensitive information (secrets) within this NixOS configuration.

---

## 🚀 Adding a New Package

User-space applications are managed declaratively using Home Manager in domain modules under `home/`:
- Developer tools, SDKs, LSPs, compilers: [home/dev.nix](file:///home/kiskaadee/Config/home/dev.nix)
- Desktop applications, GUI tools, Wayland utilities: [home/desktop.nix](file:///home/kiskaadee/Config/home/desktop.nix)
- Shell utilities, terminal enhancements: [home/shell.nix](file:///home/kiskaadee/Config/home/shell.nix)

### Step 1: Find the Package Name
Before adding a package, look up its exact attribute name:
*   **Search Engine:** Go to the official [NixOS Package Search](https://search.nixos.org/packages).
*   **CLI Search:** 
    ```bash
    nix-env -qaP '<package-name>'
    # Or using modern flake-native search:
    nix search nixpkgs <query>
    ```

### Step 2: Update the Target Domain Module
Open the appropriate module (e.g., [home/dev.nix](file:///home/kiskaadee/Config/home/dev.nix)) and append the package name into `home.packages`:

```nix
  home.packages = with pkgs; [
    # ... existing packages
    
    # Text Editors / Development
    neovim
    
    # New Package Example
    ripgrep     # Modern grep alternative for fast directory search
  ];
```

### Step 3: Test and Switch
Verify the package builds correctly before switching system-wide:
```bash
# Test build without applying
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link

# Apply configuration
sudo nixos-rebuild switch --flake .#laptop
```

---

## 🔒 Secrets Management (Operator Workflow)

The laptop acts as the administrative management station for homelab credentials using `sops` and `age`. Secrets are stored encrypted in Git under the [Core](file:///home/kiskaadee/Projects/active/homelab/Core) repository.

### Editing Homelab Secrets
To edit or rotate homelab secrets from your laptop:
```bash
sops ~/Projects/active/homelab/Core/nixos/secrets.yaml
```
SOPS uses your personal age key at `~/.config/sops/age/keys.txt` to decrypt the file locally, and re-encrypts it for both the server and your workstation upon save.

For detailed architecture diagrams and recovery steps, see the [Secrets Management Guide](docs/secrets-management.md).
