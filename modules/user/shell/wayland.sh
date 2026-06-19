# 📋 Custom Wayland Desktop Utilities
# Sourced in .bashrc to provide command-line utilities optimized for Wayland compositor environments.

# 1. wlc: Executing a command, printing output to terminal, and concurrently piping output into the Wayland clipboard.
# Optional `-h` or `--headers` inserts a command/time header at the top of clipboard content.
wlc() {
    local header_mode=false
    local cmd_str

    # Process script command line flags
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--headers) header_mode=true; shift ;;
            --) shift; break ;;
            *) break ;;
        esac
    done

    if [[ "$#" -eq 0 ]]; then
        echo "Usage: wlc [--headers] <command> [args...]" >&2
        return 1
    fi

    cmd_str="$*"

    # Execute and output
    {
        if [[ "$header_mode" == true ]]; then
            printf "# Command: %s\n" "$cmd_str"
            printf "# Date: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
            printf "# Type: combined (stdout/stderr)\n\n"
        fi
        "$@" 2>&1
    } | tee >(wl-copy) # Output to terminal and copy to clipboard buffer using wl-copy
}
