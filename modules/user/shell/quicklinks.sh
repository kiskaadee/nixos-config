# --- Quicklinks Launcher ---

quicklinks() {
    local CONFIG_FILE="$HOME/.quicklinks"
    local SELECTED_LINE
    local COMMAND

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

    SELECTED_LINE=$(bat "$CONFIG_FILE" | fzf \
        --style full \
        --height 40% --layout reverse --border \
        --prompt "🚀 Quick Access: " \
        --delimiter "|" --with-nth 1..3)

    [[ -z "$SELECTED_LINE" ]] && return 0

    COMMAND=$(echo "$SELECTED_LINE" | cut -d'|' -f3- | sed 's/^[[:space:]]*//')

    echo "🚀 Executing: $COMMAND"
    eval "$COMMAND"
}
