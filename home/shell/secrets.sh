# shellcheck shell=bash
# 🔐 Secret Extraction & Clipboard Utilities
# Sourced in .bashrc to provide quick, safe extraction of SOPS-managed secrets into the Wayland clipboard.

# 1. gh-token: Extracts the GitHub repository token from Homelab secrets directly into the Wayland clipboard.
# Uses 'sops -d --extract' to decrypt only the required key in memory without persisting plaintext to disk.
# Uses 'wl-copy -n --sensitive' to strip trailing newlines and flag the content as sensitive for clipboard managers.
gh-token() {
    local secrets_file="${HOMELAB_SECRETS_FILE:-$HOME/Homelab/Core/nixos/secrets.yaml}"

    if ! command -v sops >/dev/null 2>&1; then
        echo "Error: 'sops' is not installed or not in PATH." >&2
        return 1
    fi

    if ! command -v wl-copy >/dev/null 2>&1; then
        echo "Error: 'wl-copy' is not installed or not in PATH." >&2
        return 1
    fi

    if [[ ! -f "$secrets_file" ]]; then
        echo "Error: Secrets file not found at '$secrets_file'." >&2
        return 1
    fi

    local token
    token=$(sops -d --extract '["system"]["gh_repo_token"]' "$secrets_file" 2>/dev/null)
    local status=$?

    if [[ $status -ne 0 || -z "$token" ]]; then
        echo "Error: Failed to extract 'system.gh_repo_token' from sops." >&2
        return 1
    fi

    printf "%s" "$token" | wl-copy -n --sensitive
    unset token

    echo "GitHub repo token copied to clipboard (marked sensitive)."
}
