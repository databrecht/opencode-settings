---
description: Evolve code style guidelines through feedback
---

# Guideline Evolution

Evolve code style guidelines through feedback. Use when you don't like how the AI wrote something.

## Arguments: $ARGUMENTS

User's complaint about the code (e.g., "I don't like how you used clone here")

## Instructions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 1: Analyze Complaint
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Identify the code** user is referring to (recent edits, or ask for file:line)

2. **Detect context**:
   - Language (from file extension)
   - Action (from path: `tests/`, `*_test.rs` → testing)
   - Repo (from cwd basename or git remote)

3. **Find applicable guideline skills** using `find_skills` and the 3-part naming:
   - `<lang>-x` (language base)
   - `<lang>-<action>` (language + action)
   - Project-local skills

4. **Check if code aligns with guidelines**:
   - Load each applicable skill using `use_skill`
   - Find rules related to user's complaint
   - Determine: ALIGNED or MISALIGNED?

5. **Output analysis**:

```
┌─ Analysis ──────────────────────────────────────────────────────────────────┐
│                                                                             │
│ 📍 Code Location:   <file:line-range>                                       │
│ 🔍 Pattern Used:    <what the AI did>                                       │
│ 📚 Guideline Check: <skill-name> → "<relevant rule>"                        │
│                                                                             │
│ ⚖️  Alignment:      ✅ ALIGNED  or  ❌ MISALIGNED                           │
│                                                                             │
│ 💭 Reasoning:                                                               │
│    <Why it was written this way>                                            │
│    <How it relates to the guideline>                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 2: Resolution Path
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**If MISALIGNED:**
1. Fix the code according to existing guidelines
2. Show the fix
3. Say: "Fixed according to guidelines. Anything else?"
4. DONE

**If ALIGNED** (AI pushes back):

Show conflict box:
```
┌─ Guideline Conflict ────────────────────────────────────────────────────────┐
│                                                                             │
│ The code follows existing guidelines:                                       │
│                                                                             │
│   <skill-name> (line <N>):                                                  │
│   "<the rule that was followed>"                                            │
│                                                                             │
│ The AI believes this approach is correct because:                           │
│   • <reason 1>                                                              │
│   • <reason 2>                                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

Ask user:
- **Evolve guideline** - "I want to change/add a rule"
- **Force fix** - "You're wrong, fix it anyway"
- **Skip** - "Never mind, keep it as is"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 3: Evolve Guideline (if selected)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Ask**: "What should the rule be?" (get user's preferred behavior)

2. **Determine placement**:

```
┌─ Guideline Placement ───────────────────────────────────────────────────────┐
│                                                                             │
│ Where should this rule live?                                                │
│                                                                             │
│ Context: <lang>, <action>, <repo>                                           │
│                                                                             │
│   ○ <lang>-x              (all <lang> code everywhere)                      │
│   ○ <lang>-<action>       (<lang> <action> in any repo)                     │
│   ○ Project-local         (this project only)                               │
│   ○ Custom...                                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

3. **Update or create the skill**:
   - If skill exists: Add rule to appropriate section
   - If skill doesn't exist: Create using code-guideline-writer format
   - Show diff of changes

4. **Fix the original code** according to new guideline

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PHASE 4: Force Fix (if selected)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Apply user's preferred fix
2. Ask: "Want to add this as a guideline for the future?"
   - If yes → Go to Phase 3 step 2
   - If no → DONE
