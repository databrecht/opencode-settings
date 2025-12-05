---
description: Run test with clean visual output
---

# Run Test with Clean Output

Run a test and display results in a clean, visual format with syntax highlighting.

## Usage
```
/test <crate> <test_name_pattern>
/test <test_name_pattern>           # uses default crate if set
```

## Instructions

1. Parse arguments:
   - If two args: first is crate, second is test pattern
   - If one arg: use as test pattern, require crate from context or ask

2. Run the test with cargo:
```bash
cargo test -p <crate> "<test_pattern>" -- --nocapture 2>&1
```

3. Parse and present with highlighting:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 **TEST:** `<full_test_name>`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📦 COMPILATION:** ✓ OK or ✗ FAILED

```rust
   // If errors, show them with syntax highlighting:
   error[E0433]: failed to resolve: use of undeclared type `Foo`
    --> src/main.rs:4:5
     |
   4 |     Foo::bar()
     |     ^^^ use of undeclared type `Foo`
```

────────────────────────────────────────────────────────────────────────────────

**📋 LOGS** (relevant, last ~10)

```log
   INFO  Start task: "HeartbeatTask" id: "0876ac5f..."
   INFO  Start task: "SubscriberPollingTask" id: "0876ac5f..."
   WARN  Something to watch out for                          ← highlight warnings
   ERROR Something went wrong                                ← highlight errors
```

────────────────────────────────────────────────────────────────────────────────

**🔍 ASSERTION** (if any)

```
   expected: Exactly(0)
   actual:   1
```

────────────────────────────────────────────────────────────────────────────────

**📍 RESULT:** ✓ PASSED or ✗ FAILED

```rust
   // If failed, show panic location:
   panicked at 'Event should not be processed by renamed subscriber'
     → libs/es-postgres-tests2/tests/evolution/.../v2_engine_reading_v1_event_not_processed.rs:47
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Parsing Rules

- **Compilation errors**: Lines with `error[E` or `cannot find` → show in ```rust block
- **Warnings**: Lines with `WARN` → **bold** or highlight
- **Errors in logs**: Lines with `ERROR` → **bold** or highlight
- **Assertion info**: Lines with `assert_with_retries`, `expected:`, `actual:`
- **Failure**: Lines with `panicked at` or `FAILED`
- **Result**: Look for `test result:` line

## What to Highlight

Focus the user's attention on:
1. ⚠️ **Warnings** - might indicate the problem
2. ❌ **Errors** - likely the cause
3. 📍 **Panic location** - where to look in code
4. 🔍 **Assertion mismatch** - expected vs actual

Skip noise like:
- Unused import warnings
- Routine "Start task" logs (unless relevant)
- Duplicate log lines
