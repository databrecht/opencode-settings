---
description: Resume a paused worktree session (internal - called by /worktree)
---

# Worktree Resume (Internal)

**INTERNAL COMMAND** - Called by `/worktree` when user selects a paused session to resume.

Resume a paused session from `.opencode/worktree.md`.

**IMPORTANT**: Must be run from INSIDE a worktree directory.

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶️  RESUMING SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1. Read worktree file

```bash
cat .opencode/worktree.md
```

If this file doesn't exist, you are NOT in a paused worktree.

**Format** (YAML frontmatter + markdown body):
```markdown
---
ticket: PAY-8094
branch: bdr/PAY-8094/outstanding-quality-issues
workspace: /Users/databrecht/Repos/Bluecode/cobalt
paused_at: 2025-12-03T14:30:00Z
wip_committed: false
plan_file: ~/.config/opencode/plans/retry-config-plan.md
---

# Worktree: PAY-8094

## Summary
Working on subscriber retry configuration.

## Next Steps
- Finish implementing handler-level retry overrides
- Write tests for retry behavior

## Pending Tasks
- [ ] Add retry config to handler
- [ ] Write tests for retry behavior

## Notes
Decided to use per-handler configuration rather than global defaults.
```

### 2. Display Directory Switch Banner

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🚨 SWITCHED TO WORKTREE                                                      ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                                              ┃
┃   ›     <worktree-path>                                                      ┃
┃   ⎇     <branch-name>                                                        ┃
┃                                                                              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### 3. Check for PROGRESS.md

```bash
cat .opencode/PROGRESS.md 2>/dev/null
```

If exists:
- Read its contents
- Check for Plan file link - if it references a plan file, read that too
- Use both for context on where we left off

### 4. Restore session

1. **Load plan file** (if `plan_file` in frontmatter is set):
   - Read the plan file
   - Keep it in context for reference

2. **Restore todos** via TodoWrite:
   - Parse `## Pending Tasks` section from worktree.md
   - `- [ ]` = pending, `- [x]` = completed
   - Map to TodoWrite format

3. **Delete worktree file** (session is now active):
   ```bash
   rm .opencode/worktree.md
   ```

### 5. Propose to Continue

Display session info and propose to continue:

```
┌─ Session Restored ────────────────────────────────────────────────────────────┐
│ Ticket:  <ticket or "none">                                                   │
│ Summary: <summary>                                                            │
│ Next:    <next_steps>                                                         │
│                                                                               │
│ Pending todos:                                                                │
│   ☐ <todo 1>                                                                  │
│   ☐ <todo 2>                                                                  │
└───────────────────────────────────────────────────────────────────────────────┘

Ready to continue. Shall I proceed with: <next_steps>?
```

Always ask for confirmation before continuing.
