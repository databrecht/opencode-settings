---
description: Interactive structured code review with checkpoints
---

# Interactive Code Review

Interactive, structured review for: `$ARGUMENTS`

## Usage
```
/interactive <commit-sha>           # Review a specific commit
/interactive <sha1>..<sha2>         # Review a range
/interactive HEAD~3..HEAD           # Review last 3 commits
```

## Process

### 1. Scope Analysis
First, analyze the changed files:
```bash
git diff --name-only <range>
git diff --stat <range>
```

Build a **Todo list** of review items grouped by:
- New/modified crates (check README, public API, tests)
- Modified modules (check logic, docs, patterns)
- SQL migrations
- Test files

### 2. Interactive Review Loop

For **each** Todo item:

1. **Present** - Show the code/changes for that item
2. **Pause** - Ask: "Ready to continue, or want to discuss this?"
3. **Wait** - Let user review in their IDE
4. **Proceed** - Only continue when user confirms

Never batch multiple items. One at a time.

### 3. Checklist Per Item

For each file/module, load applicable guideline skills using `use_skill`:
- `rust-x` for general Rust rules
- `rust-testing` for test files
- Project-local skills

The skills contain the actual rules. This command orchestrates the review process.

### 4. Refactors

Refactors are allowed per item when the user allows it or asks for one.
Commit after each refactor item.
Always keep the review todo list visible.

### 5. Post-Refactor

After refactors, always ask whether the user has done their own review.

### 6. Report Template

After each item:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  REVIEW: [module/file name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ CHECKED
├─ [item]: OK
├─ [item]: OK
└─ [item]: OK

⚠️  DISCUSSION
├─ [file:line] [issue description]
└─ [file:line] [issue description]

📝 TODOs FOUND
├─ [file:line] "TODO text..."
└─ [file:line] "FIXME text..."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to continue? (or discuss any items above)
```

## Rules

- **ALWAYS validate user proposals objectively** - don't agree just to please. If user suggests a change, analyze whether it's actually positive. Push back if it's not.
- **NEVER advance to next todo** - wait for explicit user approval before moving on
- **ALWAYS pause** between items - user is reviewing in IDE
- **NEVER fix autonomously** during review - flag and discuss
- **ALWAYS flag, don't assume** - when something looks wrong, ask
- **ONE item at a time** - no batching
- **TRACK progress** - update Todo list as we go, but DON'T mark complete without user saying so
- **SCOPE discipline** - if issue is outside review scope, just note it

**BAD** - advancing without approval:
```
[finishes reviewing item 3]
"Item 3 looks good. Moving on to item 4..."
[starts reading item 4 files]
```

**GOOD** - wait for explicit go-ahead:
```
[finishes reviewing item 3]
"Item 3 looks good."
[STOP - wait for user to say "next" or "continue" or discuss]
```

**BAD** - fixing without showing:
```
"I found flakiness issues. Let me fix them."
[makes edits]
"Done, tests fixed."
```

**GOOD** - flag, show, wait:
```
"Found flakiness in timeout test - uses yield_now() which doesn't guarantee ordering.

Proposed fix:
- Use 1ms sleep instead (pragmatic for async timing tests)
- Use minutes instead of seconds for margins

Want me to make these changes?"
```

## LEARN (Mandatory)

When the user corrects you on something you missed or did wrong:
1. If the mistake isn't clearly captured in a guideline skill → **propose to update the skill**
2. Use `/guideline` to evolve the appropriate skill
3. This keeps guidelines improving over time
