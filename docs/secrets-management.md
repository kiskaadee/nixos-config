# 🔒 Secrets Management via sops-nix

This repository utilizes **`sops-nix`** (integrated with Mozilla SOPS and `age`) to manage all sensitive information (passwords, tokens, API keys) declaratively and securely. 

Secrets are stored encrypted directly in the Git repository, and decrypted dynamically at boot into memory (`/run/secrets/`), ensuring no credentials leak into the public-readable Nix store.

---

## 🛠️ Bootstrapping Secrets on a Recreated Server

If you are setting up a new host or rebuilding the system from scratch, follow these steps to configure your secrets key structure.

### Step 1: Generate a User age Key Pair
To encrypt and decrypt files on your local machine, generate a native `age` key pair:
```bash
# Create the standard config directory
mkdir -p ~/.config/sops/age

# Generate the age key pair
nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"

# Lock down key permissions
chmod 600 ~/.config/sops/age/keys.txt
```
To print your public key for configuration, run:
```bash
grep "public key" ~/.config/sops/age/keys.txt
```

### Step 2: Convert the Host SSH Public Key to age
To allow systemd to decrypt secrets automatically at boot time, obtain the host's SSH public key converted to `age` format:
```bash
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```
*Note: The private key counterpart `/etc/ssh/ssh_host_ed25519_key` is automatically read by `sops-nix` at boot with root privileges.*

### Step 3: Configure Public Keys in `.sops.yaml`
Add both the user `age` public key and the host `age` public key to the [.sops.yaml](file:///home/kiskaadee/Config/.sops.yaml) configuration file at the root of the repository:

```yaml
keys:
  - &kiskaadee age1...your_user_age_key...
  - &desktop age1...your_host_age_key...

creation_rules:
  - path_regex: hosts/desktop/secrets\.yaml$
    key_groups:
      - pgp: []
        age:
          - *kiskaadee
          - *desktop
```

---

## ✏️ Editing and Managing Secrets

Because `sops` automatically reads from your local `~/.config/sops/age/keys.txt` keyfile, you can manage secrets using simple commands:

### Create/Edit an Encrypted File
```bash
nix-shell -p sops --run "sops hosts/desktop/secrets.yaml"
```
This decrypts the file, opens it in your editor defined by `$EDITOR`, and automatically re-encrypts the values when you save and exit.

### Structure of `secrets.yaml`
Provide your keys and values as standard YAML:
```yaml
dynu_user: your-username
dynu_domain: your-domain.dynu.net
dynu_password: your-secret-password-or-hash
```

---

## 🔄 Runtime Decryption

At boot time, `sops-nix` performs the following steps:
1. Systemd runs the `sops-install-secrets` activation script.
2. The script reads `/etc/ssh/ssh_host_ed25519_key` to decrypt `hosts/desktop/secrets.yaml`.
3. The values are exposed under `/run/secrets/` as individual files (or templates) with strict user/group ownership (typically restricted to `root`).
4. Services read these paths at startup, keeping secrets secure and decoupled from the world-readable `/nix/store`.
