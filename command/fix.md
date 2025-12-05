---
description: Fix clippy warnings and format code for a crate
---

# Fix Agent

Fix clippy warnings and format code for crate: `$ARGUMENTS`

## Pre-check (MANDATORY)

**Before doing anything else:**

1. Check that exactly ONE crate is specified in `$ARGUMENTS`
   - If empty or multiple crates → STOP: "Please specify exactly one crate: /fix <crate-name>"

2. Run `git status --porcelain`
   - If output is NOT empty → STOP: "Git status is not clean. Please commit or stash changes before running /fix."
   - If output is empty → proceed

## Process

1. Find the crate's path: `cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "$ARGUMENTS") | .manifest_path'`
2. Run `cargo clippy -p $ARGUMENTS --all-features 2>&1` and filter to target crate only
3. Apply fixes by safety level (see below)
4. Run `cargo fmt -p $ARGUMENTS` to format only the target crate
5. Re-run clippy to verify
6. Present report using the template below
7. Commit changes (see Commit section)

## Safety Levels

| Level | Type | Action |
|-------|------|--------|
| 1 | Auto-fixable | Run `cargo clippy --fix -p $ARGUMENTS --all-features --allow-dirty --allow-staged` |
| 2 | Unused imports | Remove manually |
| 3 | Simple patterns | Doc comments, field shorthands, unused vars prefix `_` |
| 4 | Hairy | Fix but flag for review |

## Report Template

Always present results exactly like this:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FIX: [crate-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FIXED
├─ Auto-fix:     [n] warnings
├─ Imports:      [n] removed
├─ Formatting:   applied
├─ Shorthands:   [n] occurrences
└─ Unused vars:  [n] prefixed

⚠️  REVIEW NEEDED
├─ [file:line] [description]
└─ [file:line] [description]

REMAINING: [n] warnings (or "None - all clear!")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no items in a section, show `[none]` instead of the entries.

## Commit

After all fixes are applied, commit with this exact format:

```
[crate-path] fix (clippy & fmt)
```

Examples:
- `libs/my-lib fix (clippy & fmt)`
- `crates/my-app fix (clippy & fmt)`

Use `git add -A` then `git commit -m "[crate-path] fix (clippy & fmt)"`

## Rules
- NEVER run if git status is not clean
- NEVER run for multiple crates at once - exactly one crate per invocation
- Only fix warnings in the specified crate
- Never change logic or behavior
- When uncertain, flag for review
- Always run `cargo fmt -p <crate>` at the end (scoped to target crate)
- Always commit at the end
- **NEVER add "Generated with Claude Code", "Co-Authored-By: Claude", or similar footers to commit messages**
