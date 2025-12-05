---
description: Git worktree manager - select, resume, or create worktrees
---

# Git Worktree Manager

Unified worktree command: select existing, resume paused, or create new.

**IMPORTANT**: Run from the WORKSPACE directory (container):
```
<workspace>/                        ← run from HERE
├── <repo_folder>/                  ← main repository (default: "repo")
├── <worktrees_folder>/             ← worktrees live here (default: "worktrees")
│   └── <worktree-name>/
│       └── .opencode/worktree.md   ← paused session marker
└── <archive_folder>/               ← archived worktrees
```

## Arguments: $ARGUMENTS

- **No arguments**: Show status table + selection (resume/new/main)
- **Ticket ID** (e.g., `PAY-1234`): Create worktree for that ticket
- **Linear URL**: Create worktree from URL
- **Description** (e.g., `"fix caching"`): Create experimental worktree
- **`--no-ticket`**: Create experimental worktree (prompt for name)

## Configuration

- **Config file**: `~/.config/opencode/config/worktrees.json`:
  - `repo_folder` (default: `repo`)
  - `worktrees_folder` (default: `worktrees`)
  - `archive_folder` (default: `worktrees-archive`)
- **Branch format**: `bdr/<TICKET-ID>/<slug>` (with ticket) or `bdr/exp/<slug>` (experimental)

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 0: Determine Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Get context**:
   - Current directory: `pwd` (this is the WORKSPACE container)
   - Load `~/.config/opencode/config/worktrees.json` for folder names
   - Verify workspace structure exists

2. **Check $ARGUMENTS**:
   - **If empty**: → Go to SELECTION FLOW
   - **If has arguments**: → Go to CREATION FLOW

---

# SELECTION FLOW (no arguments)

### S1. Validate workspace structure

Check if worktrees folder exists. If not, offer to create it.

### S2. Get all worktree paths

```bash
git -C ./<repo_folder> worktree list
```

### S3. Check each worktree for paused session

For each worktree path, check if `<worktree>/.opencode/worktree.md` exists.

### S4. Display status table

```
┌─ Worktrees ───────────────────────────────────────────────────────────────────┐
│                                                                               │
│ 📁 repo (main)                   main                active                   │
│ ⏸️  eng-243-schema-migrations    bdr/ENG-243/...     paused 2h ago            │
│ ▶️  exp-test-db-template         bdr/exp/...         active                   │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### S5. Present selection

Options:
- **Resume: <worktree-name>** for each paused worktree
- **New worktree**
- **Work on main repo**

### S6. Handle selection

**If "Resume":** `cd` to worktree, display banner, run `/wt-resume`
**If "New worktree":** Ask what to work on, go to CREATION FLOW
**If "Work on main repo":** `cd` to repo, display banner

### Directory Switch Banner

**ALWAYS** display when changing directories:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🚨 SWITCHED TO WORKTREE                                                      ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                                              ┃
┃   ›     <full-path-to-worktree>                                              ┃
┃   ⎇     <branch-name>                                                        ┃
┃                                                                              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

# CREATION FLOW (with arguments)

### Phase 1: Parse Arguments

- **Linear URL**: Extract ticket ID
- **Ticket ID only**: Fetch from Linear
- **Goal description**: Search for existing tickets
- **`--no-ticket`**: Skip to worktree creation

### Phase 2: Ticket Discovery (if needed)

Search for matching tickets, present options:
- Use existing ticket
- Create new ticket
- No ticket (experimental)

### Phase 3: Ticket Creation (if needed)

Draft and confirm ticket details, create via Linear MCP.

### Phase 4: Worktree Creation

1. Compute paths and branch name
2. Show summary, confirm
3. Create worktree: `git worktree add -b <branch> <folder>`
4. Set ticket to In Progress
5. Switch to worktree, display banner
6. Report success
