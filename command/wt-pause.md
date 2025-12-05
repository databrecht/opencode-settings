---
description: Pause worktree session and save state for later
---

# Worktree Pause

Save current session state so work can be resumed later.

**Use when**: User needs to leave suddenly, switch context, or end session.

**Auto-triggered when**: User says "gtg", "bye", "gotta go", "pause", "brb" - offer to run this.

**IMPORTANT**: Run from INSIDE a worktree directory.

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸️  PAUSING SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1. Gather Context

- **Ticket**: Extract from branch name (pattern: `bdr/<TICKET-ID>/...`) or ask
- **Summary**: Write 1 sentence describing what we were working on
- **Next steps**: What needs to happen next (1-2 sentences)
- **Todos**: Capture current todo list state
- **Plan file**: If following a plan, note the plan file path

### 2. Check for Uncommitted Work

```bash
git status --porcelain
```

If dirty working tree:
- Ask: "Uncommitted changes found. Commit before pausing?"
- Options: [Yes - WIP commit] [No - leave uncommitted]
- If yes: `git add -A && git commit -m "🚧 WIP: <summary>"`

### 3. Write/Update PROGRESS.md

Create or update `.opencode/PROGRESS.md` with current state:

```markdown
# Progress: <TICKET-ID or "Experimental">

## Plan
**Plan file**: `~/.config/opencode/plans/<plan-name>.md`

## Summary
<1 sentence describing what we were working on>

## Current State
<Brief description of where things are at>

## Next Steps
<What needs to happen next - 1-3 bullet points>

## Pending Tasks
- [ ] <todo 1>
- [ ] <todo 2>

## Notes
<Any important context, decisions made, blockers encountered>

---
*Last updated: <ISO timestamp>*
```

### 4. Save Worktree File

Create `.opencode/worktree.md` with YAML frontmatter:

```markdown
---
ticket: <TICKET-ID or null>
branch: <branch-name>
workspace: <absolute-path-to-workspace-parent>
paused_at: <ISO-8601 timestamp>
wip_committed: <true|false>
plan_file: <path to plan file or null>
---

# Worktree: <TICKET-ID or "Experimental">

## Summary
<1-2 sentences about current work>

## Next Steps
- <next step 1>
- <next step 2>
- <next step 3>

## Pending Tasks
- [ ] <pending task from todos>
- [x] <completed task from todos>

## Notes
<Any important context, decisions, blockers>
```

### 5. Confirm

Display confirmation:

```
┌─ Session Paused ──────────────────────────────────────────────────────────────┐
│ Repo:      <repo/worktree name>                                               │
│ Ticket:    <TICKET-ID or "none">                                              │
│ Summary:   <summary>                                                          │
│ Next:      <next steps>                                                       │
│ Todos:     <X pending, Y completed>                                           │
│ Committed: <"🚧 WIP: ..." or "no changes" or "left uncommitted">              │
│                                                                               │
│ Worktree file: .opencode/worktree.md                                          │
│                                                                               │
│ To resume:                                                                    │
│   • Fresh session in worktree: `cd <worktree-path> && opencode`               │
│     (worktree.md will be detected and offer /wt-resume)                       │
└───────────────────────────────────────────────────────────────────────────────┘
```
