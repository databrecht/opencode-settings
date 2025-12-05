# OpenCode Global Instructions

## ON STARTUP (DO FIRST)

**IMPORTANT**: Before responding to ANY user message, check for worktree context in this order:

### Step 1: Direct worktree check
Check if `.opencode/worktree.md` exists in current directory:
```bash
ls .opencode/worktree.md 2>/dev/null
```
If found → This is a paused worktree session:
- Read the file and display a banner with ticket/branch from frontmatter
- Ask: "This is a paused worktree. Run `/wt-resume` to restore context, or start fresh?"
- **STOP here** - don't proceed to step 2

### Step 2: Workspace container check
If step 1 found nothing, check if this is a workspace container:
```bash
# Load folder name from ~/.config/opencode/config/worktrees.json (default: 'worktrees')
# Use $worktrees_folder variable in commands below
ls ./${worktrees_folder}/ 2>/dev/null
```
If a worktrees folder exists:
- Scan for paused sessions: `find ./${worktrees_folder} -name "worktree.md" -path "*/.opencode/*" 2>/dev/null`
- If paused worktrees found, display them and ask user which to resume:
  ```
  ┌─ Paused Worktrees Found ────────────────────────────────────────────────────┐
  │ ⏸️  eng-198-espg2-aggregates    ENG-198    paused 3h ago                    │
  │ ⏸️  eng-243-schema-migrations   ENG-243    paused yesterday                 │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```
- Use AskUserQuestion with options for each paused worktree + "Start fresh"
- If user selects a worktree: `cd ./${worktrees_folder}/<name>` → display SWITCHED banner → run `/wt-resume`
- If no paused worktrees OR user selects "Start fresh": run `/worktree` for full menu

### Step 3: No worktree context
If neither step found anything → continue normally

---

## Skills System

You have access to skills via Superpowers (`find_skills` and `use_skill` tools).

**Use MY skills** in `~/.config/opencode/skills/` - these take priority over Superpowers defaults.

When a task matches a skill domain, use `find_skills` to discover and `use_skill` to load:
- Writing Rust → `use_skill rust-x` (codestyle/)
- Writing tests → `use_skill rust-testing` (codestyle/)
- Event sourcing → `use_skill rust-eventsourcing` (domain/)
- Linear tickets → `use_skill linear` (meta/)
- Writing skills → `use_skill skill-writer` (meta/)
- Writing guidelines → `use_skill code-guideline-writer` (meta/)

Skills are on-demand - only load when relevant to reduce context.

---

## Auto-Triggers

| Trigger | Action |
|---------|--------|
| User says "gtg", "bye", "pause", "brb" | Offer `/wt-pause` |
| User asks question or gives feedback | See "User Questions & Pacing" below |
| Test fails and cause unclear | **ASK** - don't guess repeatedly |
| User says "theorize", "investigate", "analyse", "analyze", "propose", "suggest", "brainstorm", "explore", "evaluate", "assess", "consider" | **PROPOSE only** - no edits, present options/analysis and wait |
| User says "inquiry", "question", "clarify", "wondering", "curious", "what if", "what about", "thoughts on" | **STOP** - display speech bubble + pause all work until user says continue |

---

## User Questions & Pacing

When I ask questions or provide comments:

1. **Display in speech bubble** (easy to find when scrolling):
   ```
   ╭─────────────────────────────────────────────────────────────────────────────╮
   │ 💬 USER                                                                     │
   ├─────────────────────────────────────────────────────────────────────────────┤
   │ [User's question or comment repeated here]                                  │
   ╰─────────────────────────────────────────────────────────────────────────────╯
   ```

2. **Answer the question**

3. **STOP and wait** - do NOT automatically continue with the next task. My questions are deliberate - I may want to discuss, clarify, or redirect before moving on. Always ask for confirmation to proceed.

---

## Test Failures

When tests fail and you don't quickly understand why, **ASK ME**. Do not keep blindly trying different things (resetting databases, changing credentials, running commands repeatedly).

I have:
- Direct access to the database
- Deep understanding of the DB layout
- Knowledge of what the expected behavior should be
- Context you don't have

Don't assume you understand the expectations or can figure it out by trial and error. A quick question to me will save significant time.

---

## Phase Transitions

When moving to a new phase in a planned implementation, add a clear visual separator:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE X: [Phase Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This makes it easy to navigate through long implementation sessions and find where each phase begins.

---

## Worktree Awareness

**Folder structure convention**:

IMPORTANT: `<workspace>` is a CONTAINER directory. It is NOT the repo itself.

```
<workspace>/                        ← container directory (e.g., ~/Repos/Bluecode/cobalt/)
│
├── <repo_folder>/                  ← main repository checkout (default: "repo")
│   ├── .git/
│   ├── src/
│   └── ...
│
├── <worktrees_folder>/             ← worktrees directory (default: "worktrees")
│   └── <worktree-name>/            ← individual worktree
│       ├── .git                    ← git worktree link file
│       ├── .opencode/
│       │   └── worktree.md         ← PAUSED SESSION MARKER
│       └── src/
│
└── <archive_folder>/               ← archived worktrees (default: "worktrees-archive")
```

**Key rules**:
- `<workspace>` ≠ `<repo>` — they are DIFFERENT directories
- `<repo_folder>` is a SUBFOLDER inside `<workspace>`
- `<worktrees_folder>` is a SIBLING to `<repo_folder>` (both inside `<workspace>`)
- `worktree.md` lives at `<workspace>/<worktrees_folder>/<worktree-name>/.opencode/worktree.md`
- NEVER look for `worktree.md` in `<workspace>/` or `<workspace>/<repo_folder>/`

---

## Related Config Files

- `~/.config/opencode/config/worktrees.json` - Worktree directory config (repo_folder, worktrees_folder, archive_folder)
- Linear ticket formatting → use `skills_linear` skill when working with tickets
