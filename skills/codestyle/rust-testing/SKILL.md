---
name: rust-testing
description: Rust testing guidelines. Use when writing tests, test utilities, or test fixtures. Applies to *_test.rs files, tests/ directory, and #[test] functions.
---

# Rust Testing Guidelines

Rules specific to test code. These override `rust-x` where they differ.

## When Applied

- Files matching `*_test.rs`, `*_tests.rs`
- Files in `tests/` directory
- Functions with `#[test]` or `#[tokio::test]`
- Test utility modules (`tests/common/`)

## Error Handling in Tests

**expect() is allowed in test setup** — fail fast with context:

```rust
// ✅ In tests: expect() with message is fine
let db = TestDb::new().expect("test db should initialize");
let config = load_test_config().expect("test config missing");

// ✅ Also fine: unwrap() for infallible setup
let id = Uuid::new_v4();

// ❌ Silent failures hide bugs
let db = TestDb::new().ok();
```

**Use ? in test bodies** when testing error paths:

```rust
#[tokio::test]
async fn test_handles_missing_user() -> Result<()> {
    let db = setup_db().await?;
    let result = db.get_user(nonexistent_id).await;
    assert!(result.is_err());
    Ok(())
}
```

## Test Isolation

**Each test gets unique resources:**

```rust
// ✅ UUID-based isolation
fn test_db_name() -> String {
    format!("test_db_{}", Uuid::new_v4())
}

#[tokio::test]
async fn test_user_creation() {
    let db = TestDb::with_name(&test_db_name()).await;
    // test runs in isolated database
}

// ❌ Shared state causes flaky tests
static TEST_DB: &str = "test_database";
```

**Verify cleanup actually works:**

```rust
#[tokio::test]
async fn test_cleanup() {
    let db = TestDb::new().await;
    db.insert_data().await;

    db.cleanup().await;

    // ✅ Actually verify cleanup worked
    assert!(db.is_empty().await);
}
```

## Test Frameworks

**Use rstest for fixtures and parameterized tests:**

```rust
use rstest::*;

#[fixture]
fn test_db() -> TestDb {
    TestDb::new().expect("db setup")
}

#[rstest]
fn test_insert(test_db: TestDb) {
    // test_db is automatically provided
}

#[rstest]
#[case(0, 0)]
#[case(1, 1)]
#[case(2, 4)]
fn test_square(#[case] input: i32, #[case] expected: i32) {
    assert_eq!(input * input, expected);
}
```

**Use proptest for property-based testing:**

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_roundtrip(s: String) {
        let encoded = encode(&s);
        let decoded = decode(&encoded).unwrap();
        prop_assert_eq!(s, decoded);
    }
}
```

**Use proptest-state-machine for stateful systems:**

```rust
// Test state machines with property-based testing
prop_state_machine! {
    #[test]
    fn test_cache_operations(sequential 100 => CacheMachine);
}
```

## Test Organization

**Test utilities in `tests/common/`:**

```
tests/
├── common/
│   ├── mod.rs
│   ├── db.rs      # TestDb utilities
│   └── fixtures.rs
├── integration_test.rs
└── api_test.rs
```

**Import common utilities:**

```rust
// tests/integration_test.rs
mod common;
use common::TestDb;
```

## Snapshot Testing

**Use insta for snapshot tests:**

```rust
use insta::assert_snapshot;

#[test]
fn test_error_message() {
    let error = validate_input("bad");
    assert_snapshot!(error.to_string());
}

#[test]
fn test_json_output() {
    let output = generate_response();
    insta::assert_json_snapshot!(output);
}
```

## Async Tests

**Use #[tokio::test] for async:**

```rust
#[tokio::test]
async fn test_async_operation() {
    let result = fetch_data().await;
    assert!(result.is_ok());
}

// With specific runtime config
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_concurrent() {
    // ...
}
```

## Anti-Patterns

### ❌ DON'T: Ignore test failures

```rust
// ❌ Hiding failures
#[test]
#[ignore]
fn test_flaky() { }

// ✅ Fix or delete flaky tests
```

### ❌ DON'T: Test implementation details

```rust
// ❌ Testing private internals
assert_eq!(cache.internal_map.len(), 3);

// ✅ Test observable behavior
assert_eq!(cache.get("key"), Some(value));
```

### ❌ DON'T: Share mutable state

```rust
// ❌ Tests interfere with each other
static mut COUNTER: i32 = 0;

// ✅ Each test owns its state
let counter = AtomicI32::new(0);
```

## Test Structure (Build Time)

Prefer **one compilation target** over many separate test binaries.

**BAD** - each file in `tests/` is a separate binary (slow builds):
```
tests/
├─ test_foo.rs    # separate binary
├─ test_bar.rs    # separate binary
└─ test_baz.rs    # separate binary
```

**GOOD** - one mod.rs imports all test modules (single binary):
```
tests/
├─ mod.rs         # declares: mod failpoints; mod time_mock;
├─ failpoints/
│   ├─ mod.rs     # declares submodules + shared config
│   ├─ activate_delay.rs
│   └─ activate_error.rs
└─ time_mock/
    ├─ mod.rs
    └─ ...
```

Shared test config goes in the folder's mod.rs, not a separate common/ folder.

## Test Quality (Guard Assertions)

**DON'T be pedantic** - separate tests for trivial assertions add noise:

```rust
// ❌ BAD - separate tests for trivial assertions
#[test] fn offset_starts_at_zero() { assert!(clock.offset().is_zero()); }
#[test] fn offset_increases() { clock.advance(60); assert_eq!(clock.offset(), 60); }

// ✅ GOOD - one test with guard assertions (preconditions)
#[test]
fn advance_increases_offset() {
    let clock = Clock::new();
    assert!(clock.offset().is_zero());  // guard: document precondition

    clock.advance(Duration::from_secs(60)).await;

    assert_eq!(clock.offset().num_seconds(), 60);
}
```

Guard assertions catch setup bugs and document assumptions. If they fail, you know the problem is setup, not what you're testing.

## Test Flakiness (Critical)

Tests must be deterministic. Flag any test that could fail intermittently.

**Common flakiness sources:**

| Source | Problem | Fix |
|--------|---------|-----|
| Time assertions | `assert!(diff < 100ms)` fails under load | Use generous bounds or mock time |
| Task ordering | `yield_now()` doesn't guarantee order | Use channels/barriers for sync |
| Real time in virtual time tests | Mixing `Utc::now()` with `clock.now()` | Pick one, be consistent |
| Sleeps | `sleep(100ms)` races with other tasks | Use event-based waiting |

**BAD** - racy:

```rust
let before = Instant::now();
do_thing().await;
assert!(before.elapsed() < Duration::from_millis(10));  // ❌ fails under CPU load
```

**GOOD** - deterministic:

```rust
clock.advance(Duration::from_secs(60)).await;
assert_eq!(clock.offset().num_seconds(), 60);  // ✅ always passes
```

## Test Coverage

| Check | Action |
|-------|--------|
| Tests exist? | **Flag immediately if no tests** - this is a blocker |
| New code | Has corresponding tests? |
| Edge cases | Happy path + error paths covered? |
| Test clarity | Test name describes behavior? |
