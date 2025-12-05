#!/usr/bin/env bash
set -euo pipefail

# worktree-pause.sh - Pause current worktree session
# Usage: worktree-pause.sh [path]
# Reads from stdin: JSON context to save
# Params:
#   path: Optional. Worktree path (defaults to current directory)
# Input JSON format:
# {
#   "ticket": "ENG-198",
#   "branch": "bdr/ENG-198/aggregates",
#   "summary": "Working on aggregates feature"
# }

usage() {
    echo "Usage: worktree-pause.sh [path]" >&2
    echo "Reads JSON context from stdin" >&2
    echo "Example: echo '{\"ticket\":\"ENG-198\",\"summary\":\"test\"}' | worktree-pause.sh" >&2
    exit 1
}

# Main function
main() {
    local worktree_path="${1:-$PWD}"
    
    # Verify we're in a git worktree
    if [[ ! -f "$worktree_path/.git" ]] || ! grep -q "gitdir:" "$worktree_path/.git" 2>/dev/null; then
        echo "{\"error\":\"Not a git worktree\"}" >&2
        exit 1
    fi
    
    # Read JSON from stdin
    local context_json
    if [[ -t 0 ]]; then
        # stdin is a terminal, show usage
        usage
    else
        context_json=$(cat)
    fi
    
    # Validate JSON
    if ! echo "$context_json" | jq empty 2>/dev/null; then
        echo "{\"error\":\"Invalid JSON input\"}" >&2
        exit 1
    fi
    
    # Extract fields
    local ticket branch summary
    ticket=$(echo "$context_json" | jq -r '.ticket // ""')
    branch=$(echo "$context_json" | jq -r '.branch // ""')
    summary=$(echo "$context_json" | jq -r '.summary // ""')
    
    # If branch not provided, get from git
    if [[ -z "$branch" ]]; then
        branch=$(cd "$worktree_path" && git branch --show-current 2>/dev/null || echo "")
    fi
    
    # If ticket not provided, try to extract from branch
    if [[ -z "$ticket" && -n "$branch" ]]; then
        if [[ "$branch" =~ ^[a-z]+/([A-Z]+-[0-9]+)/ ]]; then
            ticket="${BASH_REMATCH[1]}"
        fi
    fi
    
    # Get current timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create .opencode directory
    mkdir -p "$worktree_path/.opencode"
    
    # Create worktree.md with frontmatter
    cat > "$worktree_path/.opencode/worktree.md" <<EOF
---
ticket: $ticket
branch: $branch
paused_at: $timestamp
summary: $summary
---

# Paused Worktree: $ticket

**Branch:** \`$branch\`  
**Paused:** $timestamp  

## Summary

$summary

## Resume

Run \`/wt-resume\` to restore this session context.
EOF
    
    # Return success JSON
    jq -n \
        --arg worktree_path "$worktree_path" \
        --arg ticket "$ticket" \
        --arg branch "$branch" \
        --arg paused_at "$timestamp" \
        '{
            success: true,
            worktree_path: $worktree_path,
            ticket: $ticket,
            branch: $branch,
            paused_at: $paused_at,
            file: ($worktree_path + "/.opencode/worktree.md")
        }'
}

main "$@"
