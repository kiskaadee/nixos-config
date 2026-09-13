# 🔒 Homelab & Workstation Secrets Management

This document describes the GitOps secrets management workflow using **Mozilla SOPS** and **age**.

---

## 🏛️ Architectural Model: Author vs Consumer

Secrets management follows a strict separation between **authoring** (human operator on the workstation) and **runtime consumption** (headless server):

```text
┌─────────────────────────────────────────────────────────┐
│ WORKSTATION (Author / Operator)                         │
│ - Key: ~/.config/sops/age/keys.txt (&laptop)            │
│ - Tooling: sops, age, rbw (installed in home/dev.nix)   │
│ - Action: Decrypt, edit, and re-encrypt secrets locally │
└───────────────────────────┬─────────────────────────────┘
                            │
              Git Commit (Ciphertext in repo)
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│ SERVER (Consumer / Runtime)                             │
│ - Key: /etc/ssh/ssh_host_ed25519_key (&server)          │
│ - Tooling: sops-nix systemd activation service (root)   │
│ - Action: Unattended decryption into RAM (/run/secrets) │
└─────────────────────────────────────────────────────────┘
```

* **Why editing secrets directly on the remote server fails**: The server does not have the operator's age key. Its host SSH key is owned by `root:root` with `0600` permissions and is only read by `sops-nix` during systemd activation at boot.
* **Why the workstation is the author**: The operator's private age key resides in `~/.config/sops/age/keys.txt` on the laptop. This allows secure local editing without exposing administrative keys on production nodes.

---

## 🛠️ Managing Secrets for Core

Production homelab secrets are maintained in the [Core](file:///home/kiskaadee/Projects/active/homelab/Core) repository at `Core/nixos/secrets.yaml`.

### 1. Edit Secrets Locally
From your laptop, open the encrypted secrets file:
```bash
sops ~/Projects/active/homelab/Core/nixos/secrets.yaml
```
SOPS uses your local age identity to decrypt the file and re-encrypts it for the recipients configured in `Core/.sops.yaml`, including the workstation operator and server runtime identities.

### 2. Commit and Deploy
Commit the newly encrypted ciphertext and push to your git remote:
```bash
cd ~/Projects/active/homelab/Core
git add nixos/secrets.yaml
git commit -m "chore(secrets): rotate service credentials"
git push
```
On the server, pulling and rebuilding will activate the updated secrets into `/run/secrets/`.

---

## 🔑 Workstation Key Bootstrapping

If setting up a new workstation, generate your operator `age` key pair:
```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```
To print the public key for addition to `Core/.sops.yaml`:
```bash
grep "public key" ~/.config/sops/age/keys.txt
```
