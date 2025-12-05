---
description: Complete and archive a worktree
---

# Git Worktree Done & Archive

Complete and archive worktrees. Works in two modes:
- **Inside a worktree**: Complete THIS worktree (streamlined flow)
- **At workspace root**: Review ALL worktrees (batch flow)

## Arguments: $ARGUMENTS

- No arguments: Auto-detect mode based on current directory
- Worktree name: Target specific worktree (batch mode)
- `--all`: Force batch review mode even if inside a worktree

## Configuration

- **Config file**: `~/.config/opencode/config/worktrees.json`
- **Branch format**: `bdr/<TICKET-ID>/<slug>`

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 0: Detect Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Load config from `~/.config/opencode/config/worktrees.json`
2. Get current location with `pwd` and `git rev-parse --show-toplevel`
3. Determine mode:
   - `--all` argument → BATCH REVIEW FLOW
   - Inside a worktree → SINGLE WORKTREE FLOW
   - At workspace root → BATCH REVIEW FLOW

---

# SINGLE WORKTREE FLOW

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ COMPLETING CURRENT WORKTREE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### S1. Gather Worktree Info

Get branch, last commit, check for uncommitted changes.
Extract ticket ID from branch pattern `bdr/<TICKET-ID>/...`

### S2. Check for Uncommitted Work

If uncommitted changes:
- [Commit with message]
- [Discard changes]
- [Cancel]

### S3. Ticket Actions (if ticket exists)

Fetch ticket status, display current state, ask:
- [Set to Done]
- [Add "feature-completed" label]
- [Add "feature-reviewed" label]
- [Leave as-is]
- [Cancel]

### S4. Confirm & Execute Archive

```
┌─ Archive Summary ─────────────────────────────────────────────────────────────┐
│ Worktree:     <worktree-name>                                                 │
│ Branch:       <branch>                                                        │
│ Ticket:       <TICKET-ID or "none">                                           │
│                                                                               │
│ Actions:                                                                      │
│   • <ticket action if any>                                                    │
│   • Delete target/ folder (build artifacts)                                   │
│   • Move to <archive_folder>/                                                 │
│   • Remove git worktree tracking                                              │
│   • Delete local branch (safe - fails if unmerged)                            │
└───────────────────────────────────────────────────────────────────────────────┘
```

Execute in order:
1. Apply ticket changes via Linear MCP
2. Delete target folder: `rm -rf ./target`
3. Switch to workspace root: `cd <workspace>`
4. Move to archive: `mv ./<worktrees_folder>/<name> ./<archive_folder>/`
5. Remove git worktree tracking: `git -C ./<repo_folder> worktree prune`
6. Safe delete branch: `git -C ./<repo_folder> branch -d <branch>`

### S5. Report & Offer Next Steps

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ✅ WORKTREE ARCHIVED                                                          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃   Archived:  <worktree-name> → <archive_folder>/                              ┃
┃   Ticket:    <TICKET-ID> → Done                                               ┃
┃   Branch:    <branch> deleted                                                 ┃
┃   Now at:    <workspace>/                                                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

Options:
- [Start new worktree] → `/worktree`
- [Work on main repo]
- [Done for now]

---

# BATCH REVIEW FLOW

For reviewing all worktrees at workspace root.

### Phase 1: Inventory
List all worktrees, fetch ticket status for each.

### Phase 2: Status Report
Display comprehensive table with suggestions.

### Phase 3: Human Review Gate
For tickets marked "Done" but not reviewed, ask user to confirm.

### Phase 4: Archive Proposals
Present archivable worktrees as multiselect.

### Phase 5: Execute Archive
For each selected, run archive steps.

### Phase 6: Summary Report

---

## Safety Notes

- **NEVER force-delete branches** (`git branch -D`)
- **NEVER touch remote branches**
- **Archive, don't delete** - source code preserved
- **Target folders deleted** - build artifacts not worth keeping
- **Warn about paused sessions** before archiving
