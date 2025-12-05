---
description: Validate implementation against ticket requirements
---

# Validate Ticket Implementation

Verify implementation against ticket requirements for: `$ARGUMENTS`

## Input

`$ARGUMENTS` can be:
- Linear ticket ID: `ENG-123`
- Empty: validate current branch against its ticket (from branch name)

## Instructions

### 1. Gather Context

**If ticket ID provided:**
- Fetch from Linear: requirements, acceptance criteria, linked docs

**If empty:**
- Parse branch name for ticket (e.g., `eng-198-feature` → `ENG-198`)
- Fetch that ticket from Linear

### 2. Analyze Requirements

Extract from ticket:
- Problem being solved
- Acceptance criteria
- Any linked specs or plans

### 3. Search Codebase

For each requirement/criterion:
- Search codebase for implementation
- Verify it addresses the requirement
- Mark status: ✓ Done | ⚠️ Partial | ✗ Missing

### 4. Present Validation Report

```
┌─ Ticket Validation ─────────────────────────────────────────────────────────┐
│                                                                             │
│ 📋 Ticket: ENG-XXX - <title>                                                │
│ 🌿 Branch: <current branch>                                                 │
│                                                                             │
├─ Requirements ──────────────────────────────────────────────────────────────┤
│                                                                             │
│ ✓ [Requirement 1 summary]                                                   │
│   └─ Implemented in: src/handler.rs:45-67                                   │
│                                                                             │
│ ⚠️ [Requirement 2 summary]                                                   │
│   └─ Partial: Missing edge case for X                                       │
│                                                                             │
│ ✗ [Requirement 3 summary]                                                   │
│   └─ Not found in codebase                                                  │
│                                                                             │
├─ Summary ───────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Requirements: 2/3 complete                                                  │
│                                                                             │
│ Remaining work:                                                             │
│ 1. [Most critical gap]                                                      │
│ 2. [Second priority]                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Rules

- Read-only: identify gaps, don't fix them
- Be specific: include file:line references for implementations found
- Be honest: mark partial/missing clearly
- Prioritize: list most critical gaps first
- No lint/format checks: use `/fix` for that
