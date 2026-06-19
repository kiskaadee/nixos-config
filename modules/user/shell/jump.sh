# 🗺️ Fuzzy Navigation & Directory Jump Helpers
# Sourced in .bashrc to provide quick, interactive folder traversal using Yazi and fzf.

# 1. fm: Interactive file manager wrapper using Yazi.
# Synchronizes the active terminal shell working directory to Yazi's exit folder (sticky directory).
fm() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# 2. _fuzzy_select_dir: Internal helper to locate subdirectories using fd and fzf.
_fuzzy_select_dir() {
    local base="$1"
    local query="$2"
    local max_depth="${3:-2}"
    [[ -d "$base" ]] || return 1
    fd . "$base" --type d --mindepth 1 --max-depth "$max_depth" 2>/dev/null | \
        fzf --query="$query" --select-1 --exit-0
}

# 3. _fuzzy_select_dir_preview: Internal helper displaying eza directory previews inside fzf.
_fuzzy_select_dir_preview() {
    local base="$1"
    local query="$2"
    local max_depth="${3:-2}"
    [[ -d "$base" ]] || return 1
    fd . "$base" --type d --mindepth 1 --max-depth "$max_depth" 2>/dev/null | \
        fzf --query="$query" --select-1 --exit-0 \
            --preview 'eza --tree --level 2 --icons=always --color=always {}' \
            --preview-window="right:50%:rounded"
}

# 4. _jump_to: Internal helper to safely enter a target folder and optionally list contents.
_jump_to() {
    local dir="$1"
    [[ -d "$dir" ]] || return 1
    cd "$dir" || return 1
    if [[ "$JUMP_VERBOSE" == true ]]; then
        printf "\033[1;32mJumped to:\033[0m %s\n" "$dir"
        eza -la --icons 2>/dev/null
    fi
}

# 5. jump: Primary entrypoint for fuzzy folder traversal.
# Finds a directory under the base path and enters it.
jump() {
    local dir
    dir=$(_fuzzy_select_dir_preview "$1" "$2" "${3:-2}") || return
    _jump_to "$dir"
}

# 6. _fuzzy_search_dir: Locates files containing text, and returns their parent directory.
_fuzzy_search_dir() {
    local base="$1"
    local query="$2"
    [[ -d "$base" ]] || return 1
    rg --files-with-matches --no-messages "$query" "$base" | \
        xargs -I {} dirname {} | \
        sort -u | \
        fzf --header "Search: $query"
}

# 7. jump_search: Traverses to a directory that contains a file matching a query.
jump_search() {
    local dir
    dir=$(_fuzzy_search_dir "$1" "$2") || return
    _jump_to "$dir"
}

# 8. edit_dir: Fuzzy selects a Project folder and opens Neovim directly in it.
edit_dir() {
    local dir
    dir=$(_fuzzy_select_dir "$HOME/Projects") || return
    nvim "$dir"
}

# 9. copy_dir: Fuzzy selects a directory and copies its absolute path to the clipboard.
copy_dir() {
    local dir
    dir=$(_fuzzy_select_dir "$HOME") || return
    printf "%s" "$dir" | wl-copy
}

# 10. Shorthand Navigation Aliases
cnf() { jump "$HOME/Config" "$1" 2; }  # Quickly jump inside ~/Config modules
pj()  { jump "$HOME/Projects" "$1"; }   # Jump into local workspace projects
dl()  { jump "$HOME/Downloads" "$1"; }  # Jump to Downloads
pd()  { jump "$HOME/Production" "$1"; } # Jump to Production folder
md()  { jump "/media"; }                # Jump to /media mounted storage
