---
description: Multi-agent parallel code review
---

# Code Review - Multi-Agent Parallel Review

Comprehensive code review using parallel specialized agents.

## Arguments: $ARGUMENTS

Path to review (file, folder, or `--crate <name>`)

```
/review src/handlers          # Review folder
/review src/lib.rs            # Review file
/review --crate auth          # Review crate
/review                       # Review current directory
/review --quick src/          # Skip type-design-analyzer (faster)
```

## Agents

| Agent | Focus | Confidence Threshold |
|-------|-------|---------------------|
| **@guideline-reviewer** | Project-specific coding standards (your skills) | ≥70 |
| **@bug-detector** | Logic errors, panics, race conditions | ≥70 |
| **@silent-failure-hunter** | Swallowed errors, hidden failures | ≥70 |
| **@type-design-analyzer** | Type encapsulation & invariants (skipped with --quick) | Reports scores ≤5 |

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 1: Detect Context
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Parse $ARGUMENTS**:
   - If empty: use current directory
   - If `--crate <name>`: find crate path
   - If `--quick`: set quick_mode = true
   - Otherwise: use path directly

2. **Detect language** from files in path:
   - `.rs` → rust
   - `.ts/.tsx` → typescript
   - `.py` → python
   - Mixed → review each language separately

3. **Detect action** (priority order):
   - File names: `*_test.rs`, `*_bench.rs`
   - Folder names: `tests/`, `benches/`, `examples/`
   - Crate name: ends with `-test`, `-bench`
   - Code patterns: `#[test]`, `#[bench]`
   - Default: `x` (general)

4. **Detect repo**:
   - From git: `basename $(git rev-parse --show-toplevel)`
   - Or from cwd basename
   - Default: `x`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 2: Find Applicable Skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Find skills** using `find_skills`

2. **Filter applicable** using 3-part naming `<lang>-<action>-<repo>`:
   - Match exact values OR `x` wildcard
   - Example: for `rust`, `testing`, `cobalt`:
     - `rust-x` ✓
     - `rust-testing` ✓
     - `rust-cobalt` ✓ (project-local)

3. **Show context**:

```
┌─ Review Context ────────────────────────────────────────────────────────────┐
│                                                                             │
│ Path:     <path>                                                            │
│ Language: <lang>                                                            │
│ Action:   <action>                                                          │
│ Repo:     <repo>                                                            │
│ Mode:     <full | quick>                                                    │
│                                                                             │
│ Skills to apply:                                                            │
│   1. <skill-1>                                                              │
│   2. <skill-2>                                                              │
│                                                                             │
│ Agents to spawn:                                                            │
│   • @guideline-reviewer                                                     │
│   • @bug-detector                                                           │
│   • @silent-failure-hunter                                                  │
│   • @type-design-analyzer (if not --quick)                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 3: Spawn Parallel Agents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**IMPORTANT: Mention ALL agents in a SINGLE message to run them in parallel.**

Launch these agents IN PARALLEL using @mentions:

1. **@guideline-reviewer** with:
   - path, language, action, repo
   - list of skill names to load

2. **@bug-detector** with:
   - path, language

3. **@silent-failure-hunter** with:
   - path, language

4. **@type-design-analyzer** (skip if quick_mode) with:
   - path, language

**Wait for ALL agents to complete before proceeding.**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 4: Aggregate & Filter Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Collect all findings** from agents

2. **Filter by confidence**:
   - guideline-reviewer: show confidence ≥ 70
   - bug-detector: show confidence ≥ 70
   - silent-failure-hunter: show confidence ≥ 70
   - type-design-analyzer: show types with any score ≤ 5

3. **Deduplicate**: If multiple agents flag same line, keep highest confidence

4. **Sort by severity**:
   - 🔴 Critical (90-100 confidence)
   - 🟠 High (80-89 confidence)
   - 🟡 Moderate (70-79 confidence)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 5: Show Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
┌─ Review Results ────────────────────────────────────────────────────────────┐
│                                                                             │
│ 📂 <path> (<N> files reviewed)                                              │
│ 🤖 Agents: guideline-reviewer, bug-detector, silent-failure-hunter          │
│            [, type-design-analyzer]                                         │
│                                                                             │
├─ 🔴 CRITICAL (<count>) ─────────────────────────────────────────────────────┤
│                                                                             │
│   <file>:<line>                                              [confidence]   │
│   └─ <issue description>                                                    │
│      Agent: <agent-name> │ <category/rule>                                  │
│                                                                             │
├─ 🟠 HIGH (<count>) ─────────────────────────────────────────────────────────┤
│                                                                             │
│   <file>:<line>                                              [confidence]   │
│   └─ <issue description>                                                    │
│      Agent: <agent-name> │ <category/rule>                                  │
│                                                                             │
├─ 🟡 MODERATE (<count>) ─────────────────────────────────────────────────────┤
│                                                                             │
│   <file>:<line>                                              [confidence]   │
│   └─ <issue description>                                                    │
│      Agent: <agent-name> │ <category/rule>                                  │
│                                                                             │
├─ 📐 TYPE DESIGN (if applicable) ────────────────────────────────────────────┤
│                                                                             │
│   <TypeName> (<file>:<line>)                                                │
│   └─ Scores: Enc:<N> Expr:<N> Use:<N> Enf:<N>                               │
│      Concern: <what needs attention>                                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ PASSED: <N> files with no issues                                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 6: Offer Fixes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If issues found, ask user:
- **Fix all** - Fix all issues (Critical + High first)
- **Fix critical only** - Fix only 🔴 Critical issues
- **Fix selected** - Show list, let user pick
- **Skip** - Do nothing

If fixing:
1. Apply fixes in severity order (Critical → High → Moderate)
2. Show what was changed
3. Note any issues that couldn't be auto-fixed
