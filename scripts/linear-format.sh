#!/usr/bin/env bash
set -euo pipefail

# linear-format.sh - Format Linear ticket data for display
# Usage: linear-format.sh
# Reads from stdin: Linear ticket JSON
# Returns: Formatted text output

# Main function
main() {
    # Read JSON from stdin
    local ticket_json
    if [[ -t 0 ]]; then
        echo "Error: No input provided. Pipe Linear ticket JSON to stdin" >&2
        exit 1
    else
        ticket_json=$(cat)
    fi
    
    # Validate JSON
    if ! echo "$ticket_json" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON input" >&2
        exit 1
    fi
    
    # Extract fields
    local identifier title state priority assignee_name url description
    identifier=$(echo "$ticket_json" | jq -r '.identifier // ""')
    title=$(echo "$ticket_json" | jq -r '.title // ""')
    state=$(echo "$ticket_json" | jq -r '.state.name // "Unknown"')
    priority=$(echo "$ticket_json" | jq -r '.priority // 0')
    assignee_name=$(echo "$ticket_json" | jq -r '.assignee.name // "Unassigned"')
    url=$(echo "$ticket_json" | jq -r '.url // ""')
    description=$(echo "$ticket_json" | jq -r '.description // ""')
    
    # Map priority number to label
    local priority_label
    case "$priority" in
        0) priority_label="None" ;;
        1) priority_label="Urgent" ;;
        2) priority_label="High" ;;
        3) priority_label="Medium" ;;
        4) priority_label="Low" ;;
        *) priority_label="Unknown" ;;
    esac
    
    # Format output
    cat <<EOF
┌────────────────────────────────────────────────────────────────────────────┐
│ $identifier: $title
├────────────────────────────────────────────────────────────────────────────┤
│ State:    $state
│ Priority: $priority_label
│ Assignee: $assignee_name
│ URL:      $url
├────────────────────────────────────────────────────────────────────────────┤
│ DESCRIPTION
│ 
$(echo "$description" | sed 's/^/│ /')
│
└────────────────────────────────────────────────────────────────────────────┘
EOF
}

main "$@"
