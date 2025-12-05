---
description: Linear ticket management via MCP
---

# Linear Integration

You have access to Linear via MCP tools (`mcp__linear-server__*`). Parse the user's request and execute the appropriate action.

## Input

$ARGUMENTS

## Routing

**If empty or "help"** → Show the help guide below

**Otherwise** → Parse as a Linear action:
- "my issues [filters]" → `list_issues` with `assignee: "me"`
- "search <query>" → `list_issues` with `query`
- "create <team>: <title>" → `create_issue`
- "update <id> <changes>" → `update_issue`
- "show <id>" → `get_issue`
- "comment <id>: <text>" → `create_comment`
- "teams" → `list_teams`
- "projects [team]" → `list_projects`
- "cycles <team>" → `list_cycles`
- Any other natural language → interpret and use appropriate tool

---

## Help Guide (show when args empty or "help")

### Quick Commands

| Command | Example |
|---------|---------|
| `/linear help` | Show this guide |
| `/linear my issues` | Your assigned issues |
| `/linear my issues Frontend` | Your issues in Frontend team |
| `/linear search auth bug` | Search for issues |
| `/linear show FRO-123` | Issue details |
| `/linear create PAY: Fix payment timeout` | Create issue |
| `/linear update FRO-123 status:done` | Update issue |
| `/linear comment FRO-123: Deployed to prod` | Add comment |
| `/linear teams` | List all teams |
| `/linear projects Engineering` | Team's projects |
| `/linear cycles PAY` | Team's current cycle |

### Natural Language Works Too

Just describe what you want after `/linear`:
- `/linear what's assigned to me that's urgent?`
- `/linear bugs in Frontend from last week`
- `/linear move ENG-456 to in progress and assign to me`

### Available Actions

**Read**: issues, projects, teams, cycles, documents, comments, labels, users
**Write**: create/update issues, create comments, create/update projects, create labels

### Tips

- Use **"me"** for yourself: "assign to me", "my issues"
- **Team names are flexible**: "Frontend", "FRO", full name all work
- **Statuses**: "backlog", "todo", "in progress", "done", "canceled"
- **Priorities**: "urgent", "high", "medium/normal", "low"

---

## Important: Always Show Diffs

When updating issues (`update_issue`) or any write operation that modifies existing data:
1. **Always show a readable human diff** of what will change before executing
2. Wait for user confirmation before applying the update

## Display Format

When showing tickets, use the `skills_linear` skill for formatting guidelines.
