---
name: rust-eventsourcing
description: Event sourcing patterns for Cobalt's es-postgres crate. Use when working with InjectableEvent, CorrelatedSet, idempotency keys, correlation IDs, or event injection. Handles derive macros, event status validation, and testing patterns.
---

# Event Sourcing (Cobalt)

Patterns for the `es-postgres` event sourcing system in Cobalt.

## Evolving This Skill

**This is a living document.** When encountering new patterns, gotchas, or concepts not covered here:

1. **Ask the user**: "I learned something new about event sourcing - should I add it to the skill?"
2. **Use `skill-writer`**: Always invoke the skill-writer when updating to maintain proper format
3. **Keep it focused**: Only add patterns that caused confusion or are non-obvious

## When To Use

- Defining injectable events with `#[derive(InjectableEvent)]`
- Working with correlation chains and idempotency
- Testing event injection and polling
- Understanding `CorrelatedSet` and `ExpectedCorrelationGroupStatus`

## Core Concepts

### Idempotency Key vs Correlation ID

**Different purposes, both required:**

| Concept | Purpose | Uniqueness | Derived From |
|---------|---------|------------|--------------|
| Idempotency Key | Prevents duplicate events | Unique per event | Fields identifying this event instance |
| Correlation ID | Links related events | Shared across flow | Fields identifying the business transaction |

### InjectableEvent Derive

```rust
#[derive(InjectableEvent)]
#[es(
    idempotency = ["request_id"],      // Unique per event
    correlation = ["correlation_id"],   // Shared across flow
    correlation_set = TransferEvents
)]
pub struct RequestEvent {
    pub request_id: i64,      // e.g., 1 (unique to this request)
    pub correlation_id: i64,  // e.g., 1 (identifies the transfer flow)
}

#[derive(InjectableEvent)]
#[es(
    idempotency = ["request_id"],
    correlation = ["correlation_id"],
    correlation_set = TransferEvents,
    status = { exists }  // Expects correlation group to exist
)]
pub struct ResponseEvent {
    pub request_id: i64,      // e.g., 2 (different from RequestEvent)
    pub correlation_id: i64,  // e.g., 1 (same - links them together)
}
```

**Generated keys:**

| Event | Idempotency Key | Correlation ID |
|-------|-----------------|----------------|
| `RequestEvent { request_id: 1, correlation_id: 1 }` | `RequestEvent-1` | `Transfer-1` |
| `ResponseEvent { request_id: 2, correlation_id: 1 }` | `ResponseEvent-2` | `Transfer-1` |

### CorrelatedSet

Groups events sharing the same correlation chain:

```rust
#[derive(CorrelatedSet)]
#[es(prefix = "Transfer")]  // Custom prefix (defaults to struct name)
pub struct TransferEvents;
```

All events referencing this set use `Transfer-{field_values}` as their correlation ID prefix.

### ExpectedCorrelationGroupStatus

Controls validation when injecting:

| Status | Validation | Use Case |
|--------|------------|----------|
| `new` (default) | Group must NOT exist | First event in flow |
| `exists` | Group must already exist | Response/follow-up events |
| `any` | No validation | Flexible flows |

**If validation fails, event is NOT injected.**

## Testing Patterns

### Events with `status = { exists }`

**Must wait for first event to commit before injecting follow-up:**

```rust
// Inject first event
let wait_handle = es_handle
    .idempotent_inject_event_and_wait::<ResponseSet, _>(RequestEvent { ... });

// Wait for commit (correlation group now exists)
es_handle.poll().await_count(1).await?;

// Now safe to inject with status = { exists }
es_handle.idempotent_inject_event(ResponseEvent { ... }).await?;
```

### InjectStatus

| Status | Meaning |
|--------|---------|
| `Injected` | Event successfully stored |
| `Duplicate` | Same idempotency key exists (no-op) |

## Common Mistakes

### ❌ DON'T: Same idempotency fields for request/response

```rust
// WRONG - both events would have same idempotency key!
#[es(idempotency = ["correlation_id"], ...)]
pub struct RequestEvent { pub correlation_id: i64 }

#[es(idempotency = ["correlation_id"], ...)]
pub struct ResponseEvent { pub correlation_id: i64 }
```

### ✅ DO: Unique idempotency per event type

```rust
// CORRECT - each event has unique identifying field
#[es(idempotency = ["request_id"], correlation = ["correlation_id"], ...)]
pub struct RequestEvent { pub request_id: i64, pub correlation_id: i64 }

#[es(idempotency = ["response_id"], correlation = ["correlation_id"], ...)]
pub struct ResponseEvent { pub response_id: i64, pub correlation_id: i64 }
```

### ❌ DON'T: Inject `exists` event immediately

```rust
// WRONG - correlation group doesn't exist yet!
es_handle.idempotent_inject_event(RequestEvent { ... }).await?;
es_handle.idempotent_inject_event(ResponseEvent { ... }).await?; // Fails!
```

### ✅ DO: Wait for first event to commit

```rust
// CORRECT - wait for correlation group to be created
es_handle.idempotent_inject_event_and_wait::<_, _>(RequestEvent { ... });
es_handle.poll().await_count(1).await?;
es_handle.idempotent_inject_event(ResponseEvent { ... }).await?;
```
