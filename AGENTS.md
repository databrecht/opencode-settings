# OpenCode Global Instructions

## Skills System

You have access to skills via Superpowers (`find_skills` and `use_skill` tools).

**Use MY skills** in `~/.config/opencode/skills/` - these take priority over any Superpowers defaults.

**Do NOT use these Superpowers skills** (disabled, we have our own workflow):
- tdd, writing_plans, executing_plans, git_worktrees, finishing_branches

When a task matches a skill (e.g., reviewing Rust code → load `rust-x` skill), use `find_skills` to discover and `use_skill` to load it.

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
