---
description: Parallel research using multiple search agents
---

# Research

Parallel research for: `$ARGUMENTS`

## Mode Detection

Parse `$ARGUMENTS` and detect mode:

| Pattern | Mode | Strategy |
|---------|------|----------|
| Looks like crate name (`sqlx`, `tokio`, `serde`) | **crate** | docs.rs, crates.io, GitHub |
| Starts with `web:` | **web** | Force web search |
| Starts with `ENG-` or ticket pattern | **ticket** | Linear + codebase |
| General concept/question | **concept** | Parallel web search |

## Instructions

### 1. Announce Mode

```
┌─ Research ──────────────────────────────────────────────────────────────────┐
│ Query: <$ARGUMENTS>                                                         │
│ Mode:  <detected mode>                                                      │
│ Strategy: <brief description>                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Execute Strategy

**Crate Mode:**
Use WebSearch and WebFetch to gather from:
1. docs.rs API documentation
2. crates.io metadata + features + dependencies
3. GitHub examples/usage patterns

**Concept Mode:**
Parallel searches with different angles:
- Official docs angle
- Tutorial/blog angle
- Stack Overflow/GitHub issues angle
- Comparison/alternatives angle (if relevant)

**Ticket Mode:**
1. Fetch ticket from Linear using `mcp__linear-server__get_issue`
2. Search codebase for related areas

**Web Mode:**
Multiple web searches for the query (strip `web:` prefix)

### 3. Synthesize Results

Wait for ALL searches to complete, then:

```
┌─ Research Results ──────────────────────────────────────────────────────────┐
│                                                                             │
│ ## Summary                                                                  │
│ <2-3 sentence answer to the query>                                          │
│                                                                             │
│ ## Key Findings                                                             │
│ - <finding 1 with source>                                                   │
│ - <finding 2 with source>                                                   │
│ - <finding 3 with source>                                                   │
│                                                                             │
│ ## Sources                                                                  │
│ - [Title](url)                                                              │
│ - [Title](url)                                                              │
│                                                                             │
│ ## For Crate Mode: Quick Start                                              │
│ ```toml                                                                     │
│ [dependencies]                                                              │
│ <crate> = "<version>"                                                       │
│ ```                                                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Rules

- Always perform multiple searches in parallel where possible
- Always include source URLs in final output
- Crate mode: include Cargo.toml snippet
- Keep synthesis concise - user can ask follow-ups
