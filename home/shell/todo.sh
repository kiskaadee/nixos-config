# 📝 Todo.txt & Tuxedo Productivity Helper and Syntax Highlighter
# Sourced in .bashrc to provide colorized listings and quick task management shortcuts.

_todo_color() {
    awk '
    BEGIN {
        RESET   = "\033[0m"
        DIM     = "\033[2m"
        BOLD    = "\033[1m"
        RED     = "\033[1;31m"
        YELLOW  = "\033[1;33m"
        GREEN   = "\033[1;32m"
        BLUE    = "\033[1;34m"
        MAGENTA = "\033[1;35m"
        CYAN    = "\033[1;36m"
        GRAY    = "\033[90m"
        ORANGE  = "\033[38;5;214m"
    }
    {
        line = $0
        # Mute summary footer & completed tasks
        if (line ~ /^TODO:/ || line ~ /^x /) {
            print GRAY line RESET
            next
        }
        # Highlight task number at beginning
        sub(/^[0-9]+/, CYAN "&" RESET, line)
        # Highlight priority labels
        gsub(/\(A\)/, RED "(A)" RESET, line)
        gsub(/\(B\)/, YELLOW "(B)" RESET, line)
        gsub(/\(C\)/, BLUE "(C)" RESET, line)
        gsub(/\([D-Z]\)/, MAGENTA "&" RESET, line)
        # Standalone dates (preceded by space, e.g. creation date)
        gsub(/ [0-9]{4}-[0-9]{2}-[0-9]{2}/, GRAY "&" RESET, line)
        # Highlight projects (+project) & contexts (@context)
        gsub(/\+[a-zA-Z0-9_\-]+/, GREEN "&" RESET, line)
        gsub(/@[a-zA-Z0-9_\-]+/, MAGENTA "&" RESET, line)
        # Highlight key:value metadata (e.g. due:2026-09-02)
        gsub(/[a-zA-Z0-9_\-]+:[0-9a-zA-Z_\-]+/, ORANGE "&" RESET, line)

        print line
    }'
}

todo() {
    case "$1" in
        # todo next [N] / todo n [N] -> show top N priority tasks (default: 1)
        next|n)
            shift
            local count="${1:-1}"
            tuxedo 2>/dev/null ls | head -n "$count" | _todo_color
            ;;
        # todo check-next / todo do-next / todo dn -> complete top priority task
        check-next|do-next|dn)
            local top_task
            top_task=$(tuxedo 2>/dev/null ls | head -n 1)
            if [[ -n "$top_task" ]]; then
                local task_id
                task_id=$(echo "$top_task" | awk '{print $1}')
                echo "Completing: $top_task"
                tuxedo do "$task_id"
            else
                echo "No tasks found in todo.txt"
            fi
            ;;
        # Listing commands -> pipe through syntax colorizer
        ls|list|listall|lsa|listpri|lsp|listproj|lsprj|listcon|lsc)
            tuxedo "$@" | _todo_color
            ;;
        # Default pass-through (e.g. todo, todo add "...", todo do 2, todo rm 1, etc.)
        *)
            tuxedo "$@"
            ;;
    esac
}
