# 🚀 Quicklinks Launcher Utility
# Sourced in .bashrc to provide an interactive bookmarks and command-launcher interface.
# Parses a pipe-separated config file (`~/.quicklinks`) containing custom CLI commands or URLs.

# 1. quicklinks: Evaluates custom commands stored in the `~/.quicklinks` list.
quicklinks() {
    local CONFIG_FILE="$HOME/.quicklinks"
    local SELECTED_LINE
    local COMMAND

    # Create a boilerplate/template configuration file if it doesn't already exist
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "--------------------------------------------------------"
        echo "⚠️  Quicklinks file not found!"
        echo "Please create: $CONFIG_FILE"
        echo "Format: Name | Description | Command or Script"
        echo "--------------------------------------------------------"
        
        read -p "Create a template file now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Example | This is a description | echo 'Hello World'" > "$CONFIG_FILE"
            echo "Template created. Please edit it and run the function again."
        fi
        return 1
    fi

    # Display configured entries using bat syntax-highlighting and search interactively using fzf
    SELECTED_LINE=$(bat "$CONFIG_FILE" | fzf \
        --style full \
        --height 40% --layout reverse --border \
        --prompt "🚀 Quick Access: " \
        --delimiter "|" --with-nth 1..3)

    [[ -z "$SELECTED_LINE" ]] && return 0

    # Extract the third field (the bash command) and strip leading/trailing spaces
    COMMAND=$(echo "$SELECTED_LINE" | cut -d'|' -f3- | sed 's/^[[:space:]]*//')

    echo "🚀 Executing: $COMMAND"
    eval "$COMMAND"
}
