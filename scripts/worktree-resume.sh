#!/usr/bin/env bash
set -euo pipefail

# worktree-resume.sh - Resume paused worktree session
# Usage: worktree-resume.sh [path]
# Params:
#   path: Optional. Worktree path (defaults to current directory)
# Returns: JSON with session context

# Helper function to parse worktree.md frontmatter
parse_worktree_md() {
    local worktree_md="$1"
    
    if [[ ! -f "$worktree_md" ]]; then
        echo "{\"error\":\"worktree.md not found\"}" >&2
        return 1
    fi
    
    # Extract YAML frontmatter between --- markers
    local yaml_content
    yaml_content=$(sed -n '/^---$/,/^---$/p' "$worktree_md" | sed '1d;$d')
    
    # Parse YAML to JSON
    local ticket branch paused_at summary
    ticket=$(echo "$yaml_content" | grep '^ticket:' | sed 's/ticket: *//' | tr -d '"' || echo "")
    branch=$(echo "$yaml_content" | grep '^branch:' | sed 's/branch: *//' | tr -d '"' || echo "")
    paused_at=$(echo "$yaml_content" | grep '^paused_at:' | sed 's/paused_at: *//' | tr -d '"' || echo "")
    summary=$(echo "$yaml_content" | grep '^summary:' | sed 's/summary: *//' | tr -d '"' || echo "")
    
    # Extract markdown body (everything after second ---)
    local body
    body=$(sed -n '/^---$/,/^---$/!p' "$worktree_md" | sed '1,/^---$/d')
    
    jq -n \
        --arg ticket "$ticket" \
        --arg branch "$branch" \
        --arg paused_at "$paused_at" \
        --arg summary "$summary" \
        --arg body "$body" \
        '{
            ticket: $ticket,
            branch: $branch,
            paused_at: $paused_at,
            summary: $summary,
            body: $body
        }'
}

# Main function
main() {
    local worktree_path="${1:-$PWD}"
    local worktree_md="$worktree_path/.opencode/worktree.md"
    
    # Check if worktree.md exists
    if [[ ! -f "$worktree_md" ]]; then
        echo "{\"error\":\"No paused session found. Missing .opencode/worktree.md\"}" >&2
        exit 1
    fi
    
    # Parse worktree.md
    local context
    context=$(parse_worktree_md "$worktree_md") || exit 1
    
    # Get current git context
    local current_branch
    current_branch=$(cd "$worktree_path" && git branch --show-current 2>/dev/null || echo "")
    
    # Calculate time since pause
    local paused_at resumed_at duration_seconds duration_human
    paused_at=$(echo "$context" | jq -r '.paused_at')
    resumed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    if [[ -n "$paused_at" ]]; then
        # Calculate duration (this is a simplified version, may need date command adjustments)
        local paused_epoch resumed_epoch
        paused_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$paused_at" +%s 2>/dev/null || echo "0")
        resumed_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$resumed_at" +%s 2>/dev/null || echo "0")
        duration_seconds=$((resumed_epoch - paused_epoch))
        
        # Convert to human readable
        if [[ $duration_seconds -lt 60 ]]; then
            duration_human="${duration_seconds}s"
        elif [[ $duration_seconds -lt 3600 ]]; then
            duration_human="$((duration_seconds / 60))m"
        elif [[ $duration_seconds -lt 86400 ]]; then
            duration_human="$((duration_seconds / 3600))h"
        else
            duration_human="$((duration_seconds / 86400))d"
        fi
    else
        duration_human="unknown"
    fi
    
    # Build output JSON
    echo "$context" | jq \
        --arg worktree_path "$worktree_path" \
        --arg current_branch "$current_branch" \
        --arg resumed_at "$resumed_at" \
        --arg duration "$duration_human" \
        '. + {
            worktree_path: $worktree_path,
            current_branch: $current_branch,
            resumed_at: $resumed_at,
            paused_duration: $duration
        }'
}

main "$@"
