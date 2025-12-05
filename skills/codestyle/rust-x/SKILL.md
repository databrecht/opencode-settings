---
name: rust-x
description: Base Rust guidelines for all Rust code. Use when writing Rust, reviewing ownership/lifetimes, designing APIs, handling errors, or optimizing performance. Enforces clippy pedantic lints and zero-cost abstractions.
---

# Rust Guidelines (Base)

## MCP Tools

Use `rust-analyzer` MCP tools (`mcp__rust-analyzer__*`) for navigating and understanding Rust code. Prefer over grep for semantic queries.

Write Rust that embraces ownership, leverages the type system, and follows community conventions.

## When To Use

- Writing new Rust code
- Reviewing existing Rust for idioms
- Designing public APIs
- Choosing between patterns (Result vs panic, Arc vs ownership)
- Optimizing with zero-cost abstractions

## Core Principles

### Ownership First

**Prefer borrowing over cloning.** Clone only when:
- Shared ownership is genuinely needed (`Arc` for cross-thread)
- The cost is negligible (small `Copy` types)
- API requires ownership transfer

**Services should clone cheaply.** Use `Arc<Inner>` pattern:

```rust
// ✅ Cheap clone via Arc
#[derive(Clone)]
pub struct DatabaseClient {
    inner: Arc<ClientInner>,
}

// ❌ Expensive: clones entire connection pool
#[derive(Clone)]
pub struct DatabaseClient {
    pool: ConnectionPool,
    config: Config,
}
```

### Error Handling

**Panics = programming errors only.** Contract violations, impossible states, unrecoverable bugs.

**Result = recoverable failures.** External input, I/O, user errors.

```rust
// ✅ Panic: invariant violation
fn get_unchecked(&self, index: usize) -> &T {
    assert!(index < self.len(), "index out of bounds");
    // ...
}

// ✅ Result: external input
fn parse_config(input: &str) -> Result<Config, ParseError> {
    // ...
}

// ❌ Wrong: panic on user input
fn parse_config(input: &str) -> Config {
    serde_json::from_str(input).unwrap() // Don't do this
}
```

**Library errors:** Create specific error types with context:

```rust
#[derive(Debug, thiserror::Error)]
pub enum StorageError {
    #[error("key not found: {key}")]
    NotFound { key: String },
    #[error("connection failed: {source}")]
    Connection { #[source] source: io::Error },
}
```

**Application errors:** Use `anyhow` or `eyre` for ergonomic error chains.

### Type Safety

**Strong types over primitives.** Avoid primitive obsession:

```rust
// ✅ Type-safe
struct UserId(u64);
struct OrderId(u64);

fn get_order(user: UserId, order: OrderId) -> Order;

// ❌ Easy to swap arguments
fn get_order(user_id: u64, order_id: u64) -> Order;
```

**Newtypes for domain concepts:**

```rust
pub struct EmailAddress(String);

impl EmailAddress {
    pub fn new(s: &str) -> Result<Self, ValidationError> {
        // validate format
        Ok(Self(s.to_owned()))
    }
}
```

**Builders for 4+ parameters:**

```rust
DatabaseClient::builder()
    .host("localhost")
    .port(5432)
    .pool_size(10)  // optional, has default
    .build()?
```

### API Design

**Accept flexible inputs:**

```rust
// ✅ Flexible: accepts &str, String, &String
fn open(path: impl AsRef<Path>) -> Result<File>;

// ✅ Flexible: accepts anything readable
fn parse<R: Read>(reader: R) -> Result<Data>;

// ❌ Rigid: only accepts String
fn open(path: String) -> Result<File>;
```

**Return concrete types:**

```rust
// ✅ Concrete return
fn items(&self) -> &[Item];

// ❌ Unnecessary Box
fn items(&self) -> Box<[Item]>;
```

**Hide smart pointers:**

```rust
// ✅ Clean API
pub struct Cache { inner: Arc<CacheInner> }
impl Cache {
    pub fn get(&self, key: &str) -> Option<&Value>;
}

// ❌ Leaky abstraction
pub fn get_cache() -> Arc<RwLock<HashMap<String, Value>>>;
```

**Inherent methods first, then traits:**

```rust
impl MyType {
    // Core functionality here - discoverable without imports
    pub fn process(&self) -> Result<Output>;
}

impl SomeTrait for MyType {
    fn trait_method(&self) { self.process().unwrap() }
}
```

## Naming Conventions

| Pattern | Use | Example |
|---------|-----|---------|
| `as_*` | Cheap ref-to-ref | `as_str()`, `as_bytes()` |
| `to_*` | Expensive conversion | `to_string()`, `to_vec()` |
| `into_*` | Ownership transfer | `into_inner()`, `into_iter()` |
| `*_mut` | Mutable variant | `iter_mut()`, `get_mut()` |
| `try_*` | Fallible operation | `try_from()`, `try_into()` |
| `with_*` | Builder setter | `with_capacity()` |
| `is_*` | Boolean query | `is_empty()`, `is_valid()` |

**Avoid weasel words:** `Service`, `Manager`, `Handler`, `Factory`

```rust
// ✅ Descriptive
struct Bookings;
struct BookingDispatcher;
struct ConnectionPool;

// ❌ Generic
struct BookingService;
struct BookingManager;
struct ConnectionFactory;
```

## Standard Traits

**Always implement when applicable:**

| Trait | When |
|-------|------|
| `Debug` | Always (use `#[derive(Debug)]`) |
| `Clone` | If copying makes sense |
| `Copy` | Small, trivially copyable types |
| `Default` | If there's a sensible default |
| `PartialEq`, `Eq` | If equality comparison makes sense |
| `Hash` | If used in HashMaps/HashSets |
| `Send`, `Sync` | Verify automatically derived bounds |
| `Display` | For user-facing output |
| `Error` | For error types |

### Minimize From/Into

**Prefer explicit conversion methods over `From`/`Into`:**

```rust
// ✅ Explicit - IDE can jump to definition
impl MyType {
    pub fn to_other(&self) -> OtherType { ... }
    pub fn from_other(other: &OtherType) -> Self { ... }
}
let other = my_value.to_other();

// ❌ Hides what's happening
impl From<MyType> for OtherType { ... }
let other: OtherType = my_value.into();
```

Only implement `From`/`Into` when required for library interop.

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash, Default)]
pub struct Config {
    // ...
}
```

## Iterator Patterns

**Prefer combinators over loops:**

```rust
// ✅ Idiomatic
let sum: i32 = items
    .iter()
    .filter(|x| x.is_valid())
    .map(|x| x.value)
    .sum();

// ❌ Imperative when unnecessary
let mut sum = 0;
for item in items.iter() {
    if item.is_valid() {
        sum += item.value;
    }
}
```

**But use loops when clearer:**

```rust
// ✅ Loop is clearer for complex control flow
for item in items {
    if let Some(value) = item.try_process()? {
        if value.needs_special_handling() {
            handle_special(value)?;
            continue;
        }
        results.push(value);
    }
}
```

## Clippy Configuration

Add to `Cargo.toml` or `.cargo/config.toml`:

```toml
[lints.clippy]
# Deny in CI
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"

# Warn pedantic
pedantic = { level = "warn", priority = -1 }

# Allow specific pedantic
module_name_repetitions = "allow"
must_use_candidate = "allow"
```

**Key lints to enforce:**
- `clippy::unwrap_used` - Use `?` or explicit handling
- `clippy::expect_used` - Same, with context
- `clippy::pedantic` - Catches many idiom violations
- `clippy::nursery` - Experimental but useful

## Quick Patterns

### Option/Result Chaining

```rust
// ✅ Chain with ?
let value = config.get("key")?.parse()?;

// ✅ Provide defaults
let value = config.get("key").unwrap_or(&default);

// ✅ Map for transformation
let len = name.as_ref().map(|s| s.len());
```

### Struct Updates

```rust
let config = Config {
    timeout: Duration::from_secs(30),
    ..Default::default()
};
```

### Pattern Matching

```rust
// ✅ Match exhaustively
match result {
    Ok(value) => process(value),
    Err(Error::NotFound) => return Ok(None),
    Err(e) => return Err(e),
}

// ✅ if-let for single variant
if let Some(value) = optional {
    process(value);
}
```

## Anti-Patterns

### ❌ DON'T: Clone to satisfy borrow checker

```rust
// ❌ Cloning to avoid borrow issues
let name = self.name.clone();
self.process(&name);

// ✅ Restructure to avoid the conflict
let result = self.compute_name();
self.process(&result);
```

### ❌ DON'T: Unwrap in library code

```rust
// ❌ Panics on invalid input
pub fn parse(s: &str) -> Config {
    serde_json::from_str(s).unwrap()
}

// ✅ Return Result
pub fn parse(s: &str) -> Result<Config, ParseError> {
    serde_json::from_str(s).map_err(ParseError::from)
}
```

### ❌ DON'T: String for all text

```rust
// ❌ Allocates unnecessarily
fn greet(name: String) -> String

// ✅ Borrow when possible
fn greet(name: &str) -> String
```

### ❌ DON'T: Box<dyn Trait> by default

```rust
// ❌ Runtime dispatch when not needed
fn process(handler: Box<dyn Handler>)

// ✅ Static dispatch
fn process<H: Handler>(handler: H)

// ✅ Box only when truly needed (heterogeneous collections, recursive types)
```

### Async Traits

**Use `async_trait` for trait objects with async methods:**

```rust
// ✅ Use async_trait macro
#[async_trait]
trait Storage {
    async fn get(&self, key: &str) -> Option<Value>;
}

// ❌ Manual Pin<Box<dyn Future>> patterns
trait Storage {
    fn get(&self, key: &str) -> Pin<Box<dyn Future<Output = Option<Value>> + Send + '_>>;
}
```

Type erasure with manual boxing is error-prone. `async_trait` handles it correctly.

### ❌ DON'T: Constructors on parameter objects

```rust
// ❌ Constructor on args struct
let payment = payment_args.create_payment();
let house = bricks.into_house();

// ✅ Constructor on the type being created
let payment = Payment::create(payment_args);
let house = House::build(bricks);
```

### ❌ DON'T: Panic in Drop

```rust
// ❌ Can cause double-panic abort
impl Drop for MyType {
    fn drop(&mut self) {
        self.cleanup().unwrap(); // NO!
    }
}

// ✅ Log errors, don't panic
impl Drop for MyType {
    fn drop(&mut self) {
        if let Err(e) = self.cleanup() {
            tracing::error!("cleanup failed: {e}");
        }
    }
}
```

## Logging

**Use tracing, never println:**

```rust
// ✅ Structured logging
tracing::info!(user_id = %id, "processing request");
tracing::debug!(?complex_struct, "state");

// ❌ Never in production code
println!("processing request for {}", id);
eprintln!("error: {}", e);
```

**Inline format args:**

```rust
// ✅ Inline
format!("{name} is {age}")
tracing::info!("{name} logged in")

// ❌ Positional
format!("{}", name)
tracing::info!("{} logged in", name)
```

## Async Patterns

**Store JoinHandles when cleanup needed:**

```rust
// ✅ Can await or abort later
let handle = tokio::spawn(background_task());
// ... later ...
handle.abort();

// ❌ Fire and forget - can't cancel
tokio::spawn(background_task());
```

**Document non-obvious async behavior:**

```rust
/// Runs continuously until dropped.
/// The returned future completes only on error.
async fn run_connection(&self) -> Result<()>
```

## Code Organization

**Extract helpers at 3+ repetitions.** Not before.

**Keep related code together.** Don't split prematurely into modules.

## Documentation

Docs should answer "what does this do and when would I use it?" in the first line.

| Check | Guideline |
|-------|-----------|
| First line | Answers what + when to use, in human language |
| Examples | Short runnable example beats paragraphs |
| Module docs | 1-2 sentences max, point to items |
| Internal details | If complex, suggest DESIGN.md |

**BAD docs** (flag or remove):

```rust
/// Create a new clock.  // ❌ Just repeats fn name, trivial
/// Current time: real time + offset.  // ❌ Describes trivial implementation
/// Clock with virtual time control.  // ❌ Jargon without context
```

Any doc that states the obvious - better no doc than noise.

**GOOD docs** explain WHY/HOW, not just WHAT:

```rust
/// Use instead of Utc::now() in code under test.  // ✅ Tells you WHEN to use it
/// Returns Result<T, Elapsed> to match tokio's API.  // ✅ Tells you WHY (drop-in compatible)
/// All registered time sources (DB, etc) are synced.  // ✅ Tells you WHAT ELSE happens
```

Include BOTH the what AND the why when the why isn't obvious.

## Code Review Flags

Always flag these patterns:
- `TODO`, `FIXME`, `HACK` comments - discuss each
- Dead code: unused functions, fields, imports
- Missing error handling (swallowed errors, empty catch blocks)
