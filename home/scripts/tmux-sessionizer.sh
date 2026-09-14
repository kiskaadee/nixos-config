#!/usr/bin/env bash
set -euo pipefail

# Declarative workspace roots
EXPLICIT_WORKSPACES=(
    "$HOME/Config"
    "$HOME/Brain"
    "$HOME/Homelab/Core"
)

DISCOVERY_ROOTS=(
    "$HOME/Projects"
    "$HOME/Homelab"
)

# Normalize folder basename to a valid, deterministic tmux session name
normalize_name() {
    local raw="$1"
    local name
    name=$(basename "$raw" | tr '[:upper:]' '[:lower:]' | sed -E 's/[ .]+/-/g; s/[^a-z0-9_-]//g; s/[-_]+$//')
    if [[ -z "$name" ]]; then
        echo "ERROR: normalized session name for '$raw' is empty" >&2
        return 1
    fi
    echo "$name"
}

# Discover all registered and git-backed workspaces
# Outputs tab-separated: <session_name>\t<absolute_path>
get_projects() {
    local -A seen_paths=()

    # 1. Explicit workspaces
    for ws in "${EXPLICIT_WORKSPACES[@]}"; do
        if [[ -d "$ws" ]]; then
            seen_paths["$ws"]=1
        fi
    done

    # 2. Discovered git repos under existing roots
    for root in "${DISCOVERY_ROOTS[@]}"; do
        [[ -d "$root" ]] || continue
        while IFS= read -r gitdir; do
            local pdir
            pdir=$(dirname "$gitdir")
            seen_paths["$pdir"]=1
        done < <(fd -H -d 4 -t d '^\.git$' "$root" 2>/dev/null)
    done

    # 3. Format output
    for dir in "${!seen_paths[@]}"; do
        local sname
        if sname=$(normalize_name "$dir" 2>/dev/null); then
            printf "%s\t%s\n" "$sname" "$dir"
        fi
    done | sort -k1,1
}

# Ensure the workspace registry has zero session-name collisions
validate_registry() {
    local registry="$1"
    local collisions
    collisions=$(printf "%s\n" "$registry" | awk -F'\t' '
        {
            count[$1]++
            paths[$1] = paths[$1] "\n  " $2
        }
        END {
            for (s in count) {
                if (count[s] > 1) {
                    printf "ERROR: workspace name collision: '\''%s'\''%s\n\n", s, paths[s]
                }
            }
        }
    ')

    if [[ -n "$collisions" ]]; then
        printf "%s" "$collisions" >&2
        return 1
    fi
    return 0
}

# Resolve target directory and session name from arguments or interactive selection
resolve_workspace() {
    local projects
    projects=$(get_projects)
    validate_registry "$projects" || exit 1

    if [[ $# -eq 0 ]]; then
        local selected
        selected=$(printf "%s\n" "$projects" | fzf \
            --delimiter=$'\t' \
            --with-nth=1,2 \
            --prompt="Workspace > " \
            --height=40% \
            --reverse || true)

        if [[ -z "$selected" ]]; then
            exit 0
        fi

        echo "$selected"
        return 0
    fi

    local query="$1"

    # 1. Existing directory path
    if [[ -d "$query" ]]; then
        local abs_path sname
        abs_path=$(realpath "$query")
        sname=$(normalize_name "$abs_path") || exit 1
        printf "%s\t%s\n" "$sname" "$abs_path"
        return 0
    fi

    # 2. Exact session name match
    local exact exact_cnt
    exact=$(printf "%s\n" "$projects" | awk -F'\t' -v q="$query" 'tolower($1) == tolower(q)')
    exact_cnt=$(printf "%s\n" "$exact" | grep -c -v "^$" || true)
    if [[ "$exact_cnt" -eq 1 ]]; then
        echo "$exact"
        return 0
    fi

    # 3. Exact basename match
    local base_matches base_cnt query_base
    query_base=$(basename "$query" | tr '[:upper:]' '[:lower:]')
    base_matches=$(printf "%s\n" "$projects" | awk -F'\t' -v q="$query_base" '
        {
            n = split($2, parts, "/")
            if (tolower(parts[n]) == q) print $0
        }
    ')
    base_cnt=$(printf "%s\n" "$base_matches" | grep -c -v "^$" || true)
    if [[ "$base_cnt" -eq 1 ]]; then
        echo "$base_matches"
        return 0
    elif [[ "$base_cnt" -gt 1 ]]; then
        echo "ERROR: ambiguous project basename '$query':" >&2
        printf "%s\n" "$base_matches" | awk -F'\t' '{print "  " $2}' >&2
        exit 1
    fi

    # 4. Unique Substring Match
    local sub_matches sub_cnt query_lower
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    sub_matches=$(printf "%s\n" "$projects" | awk -F'\t' -v q="$query_lower" '
        index(tolower($1), q) || index(tolower($2), q)
    ')
    sub_cnt=$(printf "%s\n" "$sub_matches" | grep -c -v "^$" || true)
    if [[ "$sub_cnt" -eq 1 ]]; then
        echo "$sub_matches"
        return 0
    elif [[ "$sub_cnt" -gt 1 ]]; then
        echo "ERROR: ambiguous match for '$query' (multiple candidates found):" >&2
        printf "%s\n" "$sub_matches" | awk -F'\t' '{printf "  %-20s %s\n", $1, $2}' >&2
        exit 1
    fi

    echo "ERROR: no workspace found matching '$query'" >&2
    exit 1
}

main() {
    local target
    target=$(resolve_workspace "$@")
    [[ -z "$target" ]] && exit 0

    local session_name target_dir
    IFS=$'\t' read -r session_name target_dir <<< "$target"

    # Ensure session exists (initialize cwd only on creation)
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -ds "$session_name" -c "$target_dir"
    fi

    # Attach or switch client based on current context
    if [[ -z "${TMUX:-}" ]]; then
        exec tmux attach-session -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    fi
}

main "$@"
