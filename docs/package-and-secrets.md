# 📦 Package & Secrets Workflow Guide

This guide covers the day-to-day workflow for managing user-space packages and sensitive information (secrets) within this NixOS configuration.

---

## 🚀 Adding a New Package

User-space applications are managed declaratively using Home Manager in [modules/user/apps.nix](file:///home/kiskaadee/Config/modules/user/apps.nix).

### Step 1: Find the Package Name
Before adding a package, look up its exact attribute name:
*   **Search Engine:** Go to the official [NixOS Package Search](https://search.nixos.org/packages).
*   **CLI Search:** 
    ```bash
    nix-env -qaP '<package-name>'
    # Or using modern flake-native search:
    nix search nixpkgs <query>
    ```

### Step 2: Update `apps.nix`
Open [modules/user/apps.nix](file:///home/kiskaadee/Config/modules/user/apps.nix) and append the package name directly into the list inside `home.packages`:

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
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link

# Apply configuration
sudo nixos-rebuild switch --flake .#desktop
```

---

## 🔒 Adding a New Secret (SOPS Workflow)

Sensitive credentials (like passwords, API keys, and environment variables) are managed using `sops-nix`.

### Step 1: Edit the Secrets File
Launch `sops` inside `nix-shell` to decrypt and edit the target secrets file (e.g., [secrets.yaml](file:///home/kiskaadee/Config/hosts/desktop/secrets.yaml)):
```bash
nix-shell -p sops --run "sops hosts/desktop/secrets.yaml"
```
Add your key-value pair under the YAML structure:
```yaml
my_new_api_key: "secure_token_goes_here"
```
*When you save and close your editor, SOPS automatically encrypts the file before saving it back to disk.*

### Step 2: Declare the Secret in Nix
To make the decrypted secret available to services or applications at runtime, register it in your Nix configuration (e.g., in [hosts/desktop/dynu.nix](file:///home/kiskaadee/Config/hosts/desktop/dynu.nix)):

```nix
sops.secrets.my_new_api_key = {
  # (Optional) Restrict file access to specific users/groups
  owner = "root";
  group = "root";
  mode = "0400";
};
```

### Step 3: Reference the Decrypted Path
Once declared, `sops-nix` exposes the decrypted value under `/run/secrets/` at boot time. You can reference the file path dynamically in your Nix configuration using:

```nix
# This resolves to "/run/secrets/my_new_api_key"
config.sops.secrets.my_new_api_key.path
```
Avoid hardcoding raw paths; instead, pass this dynamic path directly to service configurations (e.g., via `EnvironmentFile` or command-line flags).
