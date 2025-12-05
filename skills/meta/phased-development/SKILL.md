---
name: phased-development
description: Execute implementation plans in controlled phases with review gates and flexible execution modes. Use when implementing features from plans, building prototypes, or executing multi-phase work. Handles phase review, mode selection (subagent/guided/autonomous), and cross-phase changes.
---

# Phased Development

Execute implementation plans in controlled phases with explicit review gates and user choice at every decision point.

**Announce at start:** "I'm using phased-development to execute this plan."

## Overview

This skill structures implementation work into phases, each with:
- User-chosen execution mode (subagent/guided/autonomous)
- Clear review gate before moving to next phase
- Escape hatches back to planning when needed

**Prerequisites:** Requires a plan from `superpowers:brainstorming` or `superpowers:writing-plans`.

## The Flow

```
PLANNING (brainstorming → writing-plans)
  ↓
IMPLEMENTATION (this skill)
  ↓
For each PHASE:
  1. Propose execution mode
  2. USER CHOOSES mode
  3. Execute phase
  4. Review gate (approve/reject/back to planning)
  
Can jump back to PLANNING anytime
```

## Phase 1: Load and Validate Plan

**Read the plan document** from `docs/plans/YYYY-MM-DD-<name>.md`

**Present plan summary:**
```
╔═════════════════════════════════════════════════════════╗
║ PLAN LOADED: Feature Name                              ║
╠═════════════════════════════════════════════════════════╣
║ Phases:                                                 ║
║ 1. Setup infrastructure                                ║
║ 2. Core parser implementation                          ║
║ 3. UI integration                                      ║
║                                                         ║
║ Dependencies:                                           ║
║ • Phase 2 depends on Phase 1 (types)                   ║
║ • Phase 3 can start after Phase 2 API stable          ║
╚═════════════════════════════════════════════════════════╝
```

**Ask:** "Ready to start Phase 1?"

## Phase 2: Execute Each Phase

For each phase in the plan:

### Step 1: Propose Execution Mode

Present mode recommendation using decision matrix:

```
════════════════════════════════════════════════════════
🔴 PHASE N EXECUTION MODE
════════════════════════════════════════════════════════

ANALYSIS:
  Complexity:     [Low/Medium/High]
  Novelty:        [Standard/New]
  Risk:           [Low/Medium/High]
  Size:           [~XX LOC]
  Your context:   [High/Medium/Low familiarity]

RECOMMENDATION: [Mode]
REASON: [1-2 sentences explaining why]

────────────────────────────────────────────────────────
MODE OPTIONS:
────────────────────────────────────────────────────────

1. AUTONOMOUS
   • I execute the phase independently
   • Show you results at review gate
   • Best for: Low complexity, standard patterns, <50 LOC
   
2. GUIDED  
   • I show you each step before executing
   • You approve/modify before I proceed
   • Best for: New approaches, high risk, learning opportunity
   
3. SUBAGENT-DRIVEN
   • Fresh subagent per task with code review between
   • Fast iteration with quality gates
   • Best for: Well-defined spec, >100 LOC, parallelizable
   
────────────────────────────────────────────────────────
YOUR CHOICE: [1/2/3]
════════════════════════════════════════════════════════
```

**Wait for user to choose.** Their choice overrides recommendation.

### Step 2: Execute Phase

**If AUTONOMOUS chosen:**
- Execute all tasks in phase
- Proceed directly to review gate

**If GUIDED chosen:**
- Show each step before doing it
- Wait for approval/modification
- Then execute and show result
- Repeat for each step

**If SUBAGENT-DRIVEN chosen:**
- **REQUIRED SUB-SKILL:** Use `superpowers:subagent-driven-development`
- Fresh subagent per task
- Code review between tasks

### Step 3: Review Gate

**Before asking for approval, present:**

```
┌─────────────────────────────────────────────────────────┐
│ PHASE N REVIEW GATE: [Phase Name]                      │
├─────────────────────────────────────────────────────────┤
│ ✓ Code written                                          │
│   Files changed: [list with line counts]               │
│                                                         │
│ ✓ Tests pass                                            │
│   [show test output]                                    │
│                                                         │
│ ✓ Builds successfully                                   │
│   [show build output if relevant]                       │
│                                                         │
│ ✓ Meets phase success criteria                         │
│   [criteria from plan] → [evidence it's met]            │
│                                                         │
│ SUMMARY: [1-2 sentences of what was accomplished]      │
│                                                         │
│ [Approve] [Reject] [Back to Planning]                  │
└─────────────────────────────────────────────────────────┘
```

**Wait for user decision.**

### Step 4: Handle Review Decision

**If APPROVED:**
- Mark phase complete
- Move to next phase
- If last phase, proceed to completion

**If REJECTED:**

```
╭─ PHASE REJECTED ─────────────────────────────────────╮
│ Why was this rejected?                               │
│                                                      │
│ [1] Implementation issues (redo with same approach) │
│ [2] Wrong approach (replan this phase only)         │
│ [3] Requirements changed (full replan needed)       │
│ [4] Needs discussion (clarify then decide)          │
╰──────────────────────────────────────────────────────╯
```

Based on user choice:
- **1** → Redo phase with same plan
- **2** → Replan just this phase (use `superpowers:brainstorming`)
- **3** → Full planning session (may affect other phases)
- **4** → Discussion, then user decides 1-3

**If BACK TO PLANNING:**
- Note current progress
- Use `superpowers:brainstorming` to refine approach
- Update plan document
- Resume from appropriate phase

## Handling Cross-Phase Changes

**When Phase N reveals Phase M needs changes:**

```
⚠️  CROSS-PHASE ISSUE DETECTED

ISSUE: [Description of problem]
       e.g., "Phase 1's ThinkingBlock type doesn't support
              nested blocks, but Phase 3 UI needs hierarchy"

AFFECTED PHASES: [List which phases are impacted]

────────────────────────────────────────────────────────
THREE OPTIONS:
────────────────────────────────────────────────────────

1. AD-HOC SOLUTION
   • Make targeted change to earlier phase
   • Keep current phase going
   • Risk: May not be architecturally clean
   • Timeline: Fastest

2. BACK TO PLANNING
   • Redesign affected phases
   • Current phase blocked until replan complete
   • Risk: Lost work in current phase
   • Timeline: Slowest, cleanest result

3. POSTPONE
   • Document as technical debt
   • Workaround in current phase
   • Revisit after current plan complete
   • Risk: Technical debt compounds
   • Timeline: Medium

────────────────────────────────────────────────────────
YOUR CHOICE: [1/2/3]
════════════════════════════════════════════════════════
```

**Based on user choice:**

1. **Ad-hoc:** Make the change, document it, continue
2. **Planning:** Mark current phase blocked, use `superpowers:brainstorming`
3. **Postpone:** Document in `docs/technical-debt.md`, add workaround

## Decision Matrix Reference

**Use this to inform mode recommendations:**

| Factor | Autonomous | Guided | Subagent |
|--------|-----------|--------|----------|
| **Complexity** | Low | Medium-High | Medium |
| **Novelty** | Standard pattern | New approach | Well-defined spec |
| **Risk** | Low (easy rollback) | High (core feature) | Medium |
| **Size** | <50 LOC | Any | >100 LOC |
| **User context** | High familiarity | Want to learn | Trust the spec |
| **Parallelizable** | No | No | Yes (multiple tasks) |

**Remember:** User always makes final decision. Matrix is recommendation only.

## Completion

When all phases approved:

```
╔═════════════════════════════════════════════════════════╗
║ ✓ ALL PHASES COMPLETE                                  ║
╠═════════════════════════════════════════════════════════╣
║ Phase 1: ✓ Setup infrastructure                        ║
║ Phase 2: ✓ Core parser                                 ║
║ Phase 3: ✓ UI integration                              ║
║                                                         ║
║ Final verification:                                     ║
║ • All tests pass                                        ║
║ • Build succeeds                                        ║
║ • Success criteria met                                  ║
╚═════════════════════════════════════════════════════════╝
```

**Next steps:**
- Use `superpowers:verification-before-completion` for final checks
- Use `superpowers:finishing-a-development-branch` for merge/PR

## Key Principles

**User choice is paramount.** Every execution mode, every review decision, every cross-phase change - user decides.

**Transparency over speed.** Show all evidence at review gates. No "trust me it works."

**Escape hatches everywhere.** Can always jump back to planning, never locked into a bad approach.

**Document deviations.** If plan changes during execution, update the plan document or note in technical debt.

## Anti-Patterns

### ❌ DON'T: Execute multiple phases before review
```
"I completed Phase 1, 2, and 3. Here's the result!"
```

### ✅ DO: One phase at a time with review gates
```
"Phase 1 complete. [Review gate] ... Approved.
 Starting Phase 2..."
```

### ❌ DON'T: Choose execution mode for the user
```
"This is simple, I'll just do it autonomously."
```

### ✅ DO: Recommend mode but let user choose
```
"RECOMMENDATION: Autonomous (standard pattern, low risk)
 YOUR CHOICE: [1/2/3]"
```

### ❌ DON'T: Hide cross-phase issues until review
```
[Implements workaround silently]
"Phase done! (btw I changed Phase 1 a bit)"
```

### ✅ DO: Surface cross-phase issues immediately
```
"⚠️  CROSS-PHASE ISSUE: Phase 1 needs modification.
 THREE OPTIONS: [Ad-hoc/Planning/Postpone]"
```
