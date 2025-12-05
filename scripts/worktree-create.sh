#!/usr/bin/env bash
set -euo pipefail

# worktree-create.sh - Create new worktree with ticket
# Usage: worktree-create.sh <ticket_id> <slug> [base_branch]
# Params:
#   ticket_id: Linear ticket ID (e.g., ENG-198)
#   slug: Short description slug (e.g., aggregates)
#   base_branch: Optional. Branch to base from (defaults to main)
# Returns: JSON with worktree path and branch name

usage() {
    echo "Usage: worktree-create.sh <ticket_id> <slug> [base_branch]" >&2
    echo "Example: worktree-create.sh ENG-198 aggregates main" >&2
    exit 1
}

# Helper function to load config
load_config() {
    local config_file="$HOME/.config/opencode/config/worktrees.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo '{"repo_folder":"repo","worktrees_folder":"worktrees","archive_folder":"worktrees-archive"}' | jq -c '.'
        return
    fi
    
    jq -c '.' "$config_file"
}

# Helper function to find workspace root
find_workspace_root() {
    local current="$PWD"
    local config
    config=$(load_config)
    
    local worktrees_folder
    worktrees_folder=$(echo "$config" | jq -r '.worktrees_folder // "worktrees"')
    
    # Check current directory
    if [[ -d "$current/$worktrees_folder" ]]; then
        echo "$current"
        return 0
    fi
    
    # Check parent directory
    if [[ -d "$current/../$worktrees_folder" ]]; then
        cd "$current/.."
        pwd
        return 0
    fi
    
    echo "" >&2
    return 1
}

# Main function
main() {
    if [[ $# -lt 2 ]]; then
        usage
    fi
    
    local ticket_id="$1"
    local slug="$2"
    local base_branch="${3:-main}"
    
    # Validate ticket ID format
    if [[ ! "$ticket_id" =~ ^[A-Z]+-[0-9]+$ ]]; then
        echo "{\"error\":\"Invalid ticket ID format. Expected: XXX-123\"}" >&2
        exit 1
    fi
    
    # Validate slug (alphanumeric and hyphens only)
    if [[ ! "$slug" =~ ^[a-z0-9-]+$ ]]; then
        echo "{\"error\":\"Invalid slug format. Use lowercase alphanumeric and hyphens only\"}" >&2
        exit 1
    fi
    
    # Find workspace root
    local workspace_root
    workspace_root=$(find_workspace_root) || {
        echo "{\"error\":\"Not in a workspace. Run this from workspace root or worktree\"}" >&2
        exit 1
    }
    
    # Load config
    local config
    config=$(load_config)
    
    local repo_folder worktrees_folder
    repo_folder=$(echo "$config" | jq -r '.repo_folder // "repo"')
    worktrees_folder=$(echo "$config" | jq -r '.worktrees_folder // "worktrees"')
    
    local repo_path="$workspace_root/$repo_folder"
    local worktrees_path="$workspace_root/$worktrees_folder"
    
    # Verify repo exists
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "{\"error\":\"Repository not found at $repo_path\"}" >&2
        exit 1
    fi
    
    # Create worktrees directory if it doesn't exist
    mkdir -p "$worktrees_path"
    
    # Build branch name: bdr/<TICKET>/<slug>
    local branch_name="bdr/$ticket_id/$slug"
    local worktree_name="${ticket_id,,}-${slug}"  # Lowercase ticket ID
    local worktree_path="$worktrees_path/$worktree_name"
    
    # Check if worktree already exists
    if [[ -d "$worktree_path" ]]; then
        echo "{\"error\":\"Worktree already exists at $worktree_path\"}" >&2
        exit 1
    fi
    
    # Create worktree
    cd "$repo_path"
    
    # Fetch latest from remote
    git fetch origin "$base_branch" 2>&1 || true
    
    # Create worktree
    if ! git worktree add -b "$branch_name" "$worktree_path" "origin/$base_branch" 2>&1; then
        echo "{\"error\":\"Failed to create worktree\"}" >&2
        exit 1
    fi
    
    # Create .opencode directory in worktree
    mkdir -p "$worktree_path/.opencode"
    
    # Return success JSON
    jq -n \
        --arg worktree_path "$worktree_path" \
        --arg worktree_name "$worktree_name" \
        --arg branch_name "$branch_name" \
        --arg ticket_id "$ticket_id" \
        '{
            success: true,
            worktree_path: $worktree_path,
            worktree_name: $worktree_name,
            branch_name: $branch_name,
            ticket_id: $ticket_id
        }'
}

main "$@"
