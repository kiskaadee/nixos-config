# shellcheck shell=bash
# --- Word Deletion & Readline Keybindings ---
if [[ -n "$BASH_VERSION" ]] && [[ "$-" == *i* ]]; then
    # Ctrl+W: Delete entire word under cursor (backward-word + kill-word)
    bind '"\C-w": "\eb\ed"' 2>/dev/null

    # Ctrl+Delete: Forward word delete (matches Alacritty \e[3;5~)
    bind '"\e[3;5~": kill-word' 2>/dev/null

    # Ctrl+Backspace / Alt+Backspace: Backward word delete (start to cursor)
    bind '"\e\x7f": backward-kill-word' 2>/dev/null
    bind '"\e\b": backward-kill-word' 2>/dev/null
fi

# --- Visual Entry ---
# Display system information dashboard upon opening interactive shells
if [[ $- == *i* ]]; then
    fastfetch --logo none
fi

# --- Nix Command Ergonomics ---
# Ensure `nix flake check` always prints build and verification logs (-L),
# and inject GitHub personal access token via NIX_CONFIG on-demand to prevent API rate limiting.
nix() {
    local token=""
    if declare -F _get_nix_gh_token >/dev/null 2>&1; then
        token=$(_get_nix_gh_token)
    fi

    if [[ -n "$token" ]]; then
        if [[ "${1:-}" == "flake" && "${2:-}" == "check" && "$*" != *"--log-format"* && "$*" != *"-L"* ]]; then
            NIX_CONFIG="access-tokens = github.com=${token}${NIX_CONFIG:+ $NIX_CONFIG}" command nix flake check -L "${@:3}"
        else
            NIX_CONFIG="access-tokens = github.com=${token}${NIX_CONFIG:+ $NIX_CONFIG}" command nix "$@"
        fi
    else
        if [[ "${1:-}" == "flake" && "${2:-}" == "check" && "$*" != *"--log-format"* && "$*" != *"-L"* ]]; then
            command nix flake check -L "${@:3}"
        else
            command nix "$@"
        fi
    fi
}
