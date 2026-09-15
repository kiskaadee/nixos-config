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
# Ensure `nix flake check` always prints build and verification logs (-L)
nix() {
    if [[ "${1:-}" == "flake" && "${2:-}" == "check" && "$*" != *"--log-format"* && "$*" != *"-L"* ]]; then
        command nix flake check -L "${@:3}"
    else
        command nix "$@"
    fi
}
