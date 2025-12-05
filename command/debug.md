---
description: Debug test issues and detect flakiness
---

# Debug Test

Debug test issues and detect flakiness for: `$ARGUMENTS`

## Pre-check (MANDATORY)

```bash
git status --porcelain
```

**If output is NOT empty → STOP immediately:**
```
┌─ Cannot Debug ──────────────────────────────────────────────────────────────┐
│ ✗ Git status is not clean                                                   │
│                                                                             │
│ Please commit or stash your changes before running /debug.                  │
│ This ensures any temporary traces can be safely rolled back.                │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Modes

| Command | Purpose |
|---------|---------|
| `/debug <test>` | Analyze failing test |
| `/debug flaky <test>` | Detect flakiness (run 5x) |
| `/debug trace <test>` | Add temp prints, run, rollback |

## Instructions

### Mode: Analyze (default)

1. Run the test with full output:
   ```bash
   cargo test -p <crate> "<test_pattern>" -- --nocapture 2>&1
   ```

2. Parse output for:
   - Panic location and message
   - Assertion failures (expected vs actual)
   - Error logs
   - Timing information

3. **Determine if DB access needed:**
   - Look for DB-related errors (connection, query, state)
   - If yes → proceed to DB Access section below
   - If no → skip DB

4. Present analysis (NO fixes, suggestions only)

### Mode: Flaky

1. Run test 5 times, capture each result:
   ```bash
   for i in {1..5}; do
     cargo test -p <crate> "<test>" -- --nocapture 2>&1
   done
   ```

2. Track for each run:
   - Pass/Fail
   - Duration
   - Any different error messages

3. Detect flaky patterns:
   - Inconsistent pass/fail → **FLAKY**
   - Timing variations >20% → timing-sensitive
   - Different errors each run → race condition likely

4. Report findings

### Mode: Trace

1. Identify key locations for debug prints
2. **Show user what traces will be added:**
   ```
   ┌─ Proposed Traces ────────────────────────────────────────────────────────┐
   │                                                                          │
   │ Will add temporary debug prints at:                                      │
   │ 1. src/handler.rs:45  - before async call                                │
   │ 2. src/handler.rs:67  - after result                                     │
   │ 3. src/service.rs:23  - inside loop                                      │
   │                                                                          │
   │ Proceed? (prints will be rolled back after test run)                     │
   └──────────────────────────────────────────────────────────────────────────┘
   ```

3. If approved:
   - Add `eprintln!("[DEBUG:n] ...")` statements
   - Run test once
   - Capture output
   - **IMMEDIATELY rollback:** `git checkout -- .`
   - Present trace analysis

## DB Access

**Only if determined necessary from error analysis:**

1. **Ask user first:**
   ```
   ┌─ Database Access ────────────────────────────────────────────────────────┐
   │                                                                          │
   │ Test appears to involve database. I found in .env:                       │
   │                                                                          │
   │   DATABASE_URL=postgres://user@localhost:5432/mydb                       │
   │   (or PGHOST, PGUSER, etc.)                                              │
   │                                                                          │
   │ May I query the database to check state? (read-only)                     │
   │                                                                          │
   │ Specifically, I want to check:                                           │
   │ - [ ] Table X for expected records                                       │
   │ - [ ] Sequence/ID state                                                  │
   │                                                                          │
   └──────────────────────────────────────────────────────────────────────────┘
   ```

2. If approved, use `psql` or `pg_cli` for read-only queries

3. Include DB state in analysis

## Report Template

```
┌─ Debug Report ──────────────────────────────────────────────────────────────┐
│                                                                             │
│ 🧪 Test: <full test name>                                                   │
│ 📦 Crate: <crate>                                                           │
│ 🔄 Mode: <analyze|flaky|trace>                                              │
│                                                                             │
├─ Findings ──────────────────────────────────────────────────────────────────┤
│                                                                             │
│ <mode-specific findings>                                                    │
│                                                                             │
├─ Likely Cause ──────────────────────────────────────────────────────────────┤
│                                                                             │
│ <analysis of root cause>                                                    │
│                                                                             │
├─ Suggestions ───────────────────────────────────────────────────────────────┤
│                                                                             │
│ 1. <suggestion - user decides whether to implement>                         │
│ 2. <suggestion>                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Rules

- **NEVER** start if git is dirty
- **NEVER** edit code permanently
- **Trace mode**: ALL changes rolled back via `git checkout -- .`
- **DB access**: Ask first, propose what to check, wait for approval
- **Output**: Analysis and suggestions only - user decides what to fix
- **No fixes**: This is `/debug`, not `/fix`
