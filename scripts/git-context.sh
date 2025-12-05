#!/usr/bin/env bash
set -euo pipefail

# git-context.sh - Get git repository state
# Returns JSON with branch, status, commits, and changes
# Usage: git-context.sh [path]
# Params:
#   path: Optional. Git repository path (defaults to current directory)

# Helper function to extract ticket from branch name
extract_ticket_from_branch() {
    local branch="$1"
    
    # Pattern: bdr/<TICKET>/<slug> or similar
    if [[ "$branch" =~ ^[a-z]+/([A-Z]+-[0-9]+)/ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Main function
main() {
    local repo_path="${1:-$PWD}"
    
    # Change to repo directory
    cd "$repo_path" || {
        echo '{"error":"Invalid repository path"}' >&2
        exit 1
    }
    
    # Check if this is a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo '{"error":"Not a git repository"}' >&2
        exit 1
    fi
    
    # Get current branch
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [[ -z "$branch" ]]; then
        # Detached HEAD state
        branch=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    fi
    
    # Extract ticket from branch name
    local ticket
    ticket=$(extract_ticket_from_branch "$branch")
    
    # Get git status information
    local is_clean="false"
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        is_clean="true"
    fi
    
    # Count changes
    local staged_count unstaged_count untracked_count
    staged_count=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    unstaged_count=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    untracked_count=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    
    # Get list of changed files
    local staged_files unstaged_files untracked_files
    staged_files=$(git diff --cached --name-only 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')
    unstaged_files=$(git diff --name-only 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')
    untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')
    
    # Get recent commits (last 5)
    local commits
    commits=$(git log -5 --pretty=format:'{"hash":"%h","message":"%s","author":"%an","date":"%ai"}' 2>/dev/null | jq -s '.' || echo '[]')
    
    # Check if branch tracks remote
    local remote_branch tracking
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
    if [[ -n "$remote_branch" ]]; then
        tracking="true"
        
        # Count commits ahead/behind
        local ahead behind
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    else
        tracking="false"
        ahead="0"
        behind="0"
    fi
    
    # Get stash count
    local stash_count
    stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    
    # Build JSON output
    jq -n \
        --arg branch "$branch" \
        --arg ticket "$ticket" \
        --arg is_clean "$is_clean" \
        --arg staged_count "$staged_count" \
        --arg unstaged_count "$unstaged_count" \
        --arg untracked_count "$untracked_count" \
        --argjson staged_files "$staged_files" \
        --argjson unstaged_files "$unstaged_files" \
        --argjson untracked_files "$untracked_files" \
        --argjson commits "$commits" \
        --arg tracking "$tracking" \
        --arg remote_branch "$remote_branch" \
        --arg ahead "$ahead" \
        --arg behind "$behind" \
        --arg stash_count "$stash_count" \
        '{
            branch: $branch,
            ticket: $ticket,
            status: {
                is_clean: ($is_clean == "true"),
                staged: {
                    count: ($staged_count | tonumber),
                    files: $staged_files
                },
                unstaged: {
                    count: ($unstaged_count | tonumber),
                    files: $unstaged_files
                },
                untracked: {
                    count: ($untracked_count | tonumber),
                    files: $untracked_files
                }
            },
            commits: $commits,
            remote: {
                tracking: ($tracking == "true"),
                branch: $remote_branch,
                ahead: ($ahead | tonumber),
                behind: ($behind | tonumber)
            },
            stash_count: ($stash_count | tonumber)
        }'
}

main "$@"
