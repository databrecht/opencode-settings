---
name: linear
description: Linear ticket display format and metadata handling. Use when displaying Linear tickets, working with ticket information, or managing LINEAR-metadata.json cache. Provides consistent formatting for ticket display.
---

# Linear Ticket Display

Format and display Linear tickets consistently.

## When To Use

- Displaying Linear ticket information
- Fetching ticket details via MCP
- Managing LINEAR-metadata.json cache
- Creating or updating tickets

## Ticket Display Format

When displaying Linear tickets, use this format for readability:

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║ 🎫 {IDENTIFIER}                                                    {STATUS}   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ {TITLE}                                                                       ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─ Meta ────────────────────────────────────────────────────────────────────────┐
│ Team:      {team}                                                             │
│ Assignee:  {assignee}                                                         │
│ Created:   {date} by {creator}                                                │
│ Updated:   {date}                                                             │
│ Labels:    {labels or "(none)"}                                               │
│ Parent:    {parent identifier or "(none)"}                                    │
│ Branch:    {gitBranchName}                                                    │
└───────────────────────────────────────────────────────────────────────────────┘

┌─ Description ─────────────────────────────────────────────────────────────────┐

{Rendered markdown description - properly formatted, not raw JSON}

└───────────────────────────────────────────────────────────────────────────────┘

┌─ Comments ({count}) ──────────────────────────────────────────────────────────┐
│                                                                               │
│ 💬 {Author} · {date}                                                          │
│ ──────────────────────────────────────────────────────────────────────────    │
│ {comment body}                                                                │
│                                                                               │
│ 💬 {Author} · {date}                                                          │
│ ──────────────────────────────────────────────────────────────────────────    │
│ {comment body}                                                                │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘

🔗 {url}
```

## Display Guidelines

1. **Header box** - Identifier and status at a glance, title prominent
2. **Meta section** - Keep compact, omit fields that are empty/irrelevant
3. **Description** - Render markdown properly (headers, lists, code blocks)
4. **Comments** - Show in chronological order (oldest first), include author and date
5. **Link** - Always include the URL at the bottom for quick access

## When to Omit Sections

- Omit **Comments** section if there are no comments
- Omit **Parent** line if there's no parent issue
- Omit **Labels** line if empty (or show "(none)")
- Omit **Branch** line if not set

---

## linear-metadata.json

Cache file for frequently used parent tickets and projects. Located at `~/.config/opencode/config/linear-metadata.json`.

### Structure

```json
{
  "branch_prefix": "bdr",
  "default_team": "Engineering",
  "parent_tickets": [
    {
      "id": "9e13dea4-aee8-4ac5-98ab-1a2813990ce0",
      "identifier": "ENG-100",
      "title": "ES v2 Overhaul",
      "added": "2025-12-01T10:00:00Z"
    }
  ],
  "projects": [
    {
      "id": "abc123-def456",
      "name": "Event Sourcing v2",
      "added": "2025-12-01T10:00:00Z"
    }
  ]
}
```

### Fields

| Field | Description |
|-------|-------------|
| `branch_prefix` | User's branch prefix (e.g., initials like "bdr") |
| `default_team` | Default team for new tickets |
| `parent_tickets` | Cached parent tickets for quick selection |
| `projects` | Cached projects for quick selection |
| `added` | ISO timestamp when entry was cached |

### Maintenance

- **Auto-cleanup**: Tickets with status "Done" are automatically removed
- **Manual cleanup**: User prompted to remove stale entries when adding new ones
- **Only query Linear** when user selects "Search..." for custom lookup

### Used By

- `/worktree` - For parent ticket/project selection when creating tickets
- `/wt-done` - For cleanup after archiving completed worktrees
