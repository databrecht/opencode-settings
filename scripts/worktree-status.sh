#!/usr/bin/env bash
set -euo pipefail

# worktree-status.sh - Get complete worktree environment state
# Returns JSON describing current location and all worktrees
# Usage: worktree-status.sh [workspace_path]
# Params:
#   workspace_path: Optional. If not provided, uses current directory

# Helper function to load config
load_config() {
    local config_file="$HOME/.config/opencode/config/worktrees.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo '{"repo_folder":"repo","worktrees_folder":"worktrees","archive_folder":"worktrees-archive"}' | jq -c '.'
        return
    fi
    
    jq -c '.' "$config_file"
}

# Helper function to get git root
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null || echo ""
}

# Helper function to parse worktree.md frontmatter
parse_worktree_md() {
    local worktree_md="$1"
    
    if [[ ! -f "$worktree_md" ]]; then
        echo "{}"
        return
    fi
    
    # Extract YAML frontmatter between --- markers
    local yaml_content
    yaml_content=$(sed -n '/^---$/,/^---$/p' "$worktree_md" | sed '1d;$d')
    
    # Parse YAML to JSON (simple parsing, assumes key: value format)
    local ticket branch paused_at summary
    ticket=$(echo "$yaml_content" | grep '^ticket:' | sed 's/ticket: *//' | tr -d '"' || echo "")
    branch=$(echo "$yaml_content" | grep '^branch:' | sed 's/branch: *//' | tr -d '"' || echo "")
    paused_at=$(echo "$yaml_content" | grep '^paused_at:' | sed 's/paused_at: *//' | tr -d '"' || echo "")
    summary=$(echo "$yaml_content" | grep '^summary:' | sed 's/summary: *//' | tr -d '"' || echo "")
    
    jq -n \
        --arg ticket "$ticket" \
        --arg branch "$branch" \
        --arg paused_at "$paused_at" \
        --arg summary "$summary" \
        '{ticket: $ticket, branch: $branch, paused_at: $paused_at, summary: $summary}'
}

# Helper function to check if path is a worktree
is_worktree() {
    local path="$1"
    [[ -f "$path/.git" ]] && grep -q "gitdir:" "$path/.git" 2>/dev/null
}

# Main function
main() {
    local current_dir="${1:-$PWD}"
    local config
    config=$(load_config)
    
    local repo_folder worktrees_folder archive_folder
    repo_folder=$(echo "$config" | jq -r '.repo_folder // "repo"')
    worktrees_folder=$(echo "$config" | jq -r '.worktrees_folder // "worktrees"')
    archive_folder=$(echo "$config" | jq -r '.archive_folder // "worktrees-archive"')
    
    # Detect location type
    local location="unknown"
    local workspace_root=""
    local current_worktree=""
    local paused_worktrees=()
    local active_worktrees=()
    
    # Check if current directory has .opencode/worktree.md
    if [[ -f "$current_dir/.opencode/worktree.md" ]]; then
        location="paused_worktree"
        workspace_root=$(dirname "$current_dir")
        current_worktree=$(basename "$current_dir")
    # Check if current directory has worktrees/ subdirectory
    elif [[ -d "$current_dir/$worktrees_folder" ]]; then
        location="workspace"
        workspace_root="$current_dir"
    # Check if we're inside a worktree (parent has worktrees/ directory)
    elif [[ -d "$current_dir/../$worktrees_folder" ]] && is_worktree "$current_dir"; then
        location="active_worktree"
        workspace_root=$(cd "$current_dir/.." && pwd)
        current_worktree=$(basename "$current_dir")
    # Check if we're in the main repo
    elif [[ -d "$current_dir/../$worktrees_folder" ]] && [[ -d "$current_dir/.git" ]]; then
        location="main_repo"
        workspace_root=$(cd "$current_dir/.." && pwd)
    else
        location="unknown"
    fi
    
    # If we found a workspace, scan for worktrees
    if [[ -n "$workspace_root" && -d "$workspace_root/$worktrees_folder" ]]; then
        # Find all worktrees
        for wt_path in "$workspace_root/$worktrees_folder"/*; do
            if [[ -d "$wt_path" ]]; then
                local wt_name
                wt_name=$(basename "$wt_path")
                
                # Check if paused
                if [[ -f "$wt_path/.opencode/worktree.md" ]]; then
                    local metadata
                    metadata=$(parse_worktree_md "$wt_path/.opencode/worktree.md")
                    
                    local wt_json
                    wt_json=$(jq -n \
                        --arg name "$wt_name" \
                        --arg path "$wt_path" \
                        --argjson metadata "$metadata" \
                        '{name: $name, path: $path, ticket: $metadata.ticket, branch: $metadata.branch, paused_at: $metadata.paused_at, summary: $metadata.summary}')
                    
                    paused_worktrees+=("$wt_json")
                else
                    # Active worktree - get branch info
                    local branch=""
                    if [[ -f "$wt_path/.git" ]]; then
                        branch=$(cd "$wt_path" && git branch --show-current 2>/dev/null || echo "")
                    fi
                    
                    local wt_json
                    wt_json=$(jq -n \
                        --arg name "$wt_name" \
                        --arg path "$wt_path" \
                        --arg branch "$branch" \
                        '{name: $name, path: $path, branch: $branch}')
                    
                    active_worktrees+=("$wt_json")
                fi
            fi
        done
    fi
    
    # Build JSON output
    local paused_json="[]"
    if [[ ${#paused_worktrees[@]} -gt 0 ]]; then
        paused_json=$(printf '%s\n' "${paused_worktrees[@]}" | jq -s '.')
    fi
    
    local active_json="[]"
    if [[ ${#active_worktrees[@]} -gt 0 ]]; then
        active_json=$(printf '%s\n' "${active_worktrees[@]}" | jq -s '.')
    fi
    
    jq -n \
        --arg location "$location" \
        --arg workspace_root "$workspace_root" \
        --arg current_worktree "$current_worktree" \
        --argjson paused "$paused_json" \
        --argjson active "$active_json" \
        --argjson config "$config" \
        '{
            location: $location,
            workspace_root: $workspace_root,
            current_worktree: $current_worktree,
            paused_worktrees: $paused,
            active_worktrees: $active,
            config: $config
        }'
}

main "$@"
