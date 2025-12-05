---
name: code-guideline-writer
description: Creates and evolves code style guidelines as skills. Use when writing coding standards, style guides, or evolving existing code guidelines. Uses 3-part naming convention with wildcards.
---

# Code Guideline Writer

Write and evolve code style guidelines using the 3-part naming convention.

## Naming Convention

**Format: `<language>-<action>-<repo>`**

Use `x` as wildcard for "any":

```
rust-x-x              → All Rust code everywhere
rust-testing-x        → Rust testing in any repo
rust-x-cobalt         → All Rust in cobalt repo
rust-testing-cobalt   → Rust testing in cobalt (most specific)
x-testing-x           → Testing in ANY language
x-x-cobalt            → Any code in cobalt repo
```

## Skill Directory Structure

Skills are organized by category:

```
~/.config/opencode/skills/
├── codestyle/                 # Code style guidelines
│   ├── rust-x/SKILL.md        # Base Rust guidelines
│   └── rust-testing/SKILL.md  # Rust testing guidelines
├── domain/                    # Domain knowledge
│   └── rust-eventsourcing/SKILL.md
└── meta/                      # Meta-skills (writers)
    ├── code-guideline-writer/SKILL.md
    ├── skill-writer/SKILL.md
    └── linear/SKILL.md
```

## Load Order (Specificity)

Skills load from **least specific → most specific**. Later skills override earlier ones.

```
1. x-x-x              (universal - rare)
2. <lang>-x-x         (language base)
3. x-<action>-x       (action across languages)
4. <lang>-<action>-x  (language + action)
5. x-x-<repo>         (repo base)
6. <lang>-x-<repo>    (language + repo)
7. x-<action>-<repo>  (action + repo)
8. <lang>-<action>-<repo>  (most specific)
```

## Placement Decision Tree

When adding a new rule, ask:

```
Is this rule language-specific?
├─ NO  → x-<action>-<repo>
└─ YES → <lang>-?-?
         │
         Is this rule action-specific (testing, benchmarks, etc)?
         ├─ NO  → <lang>-x-<repo>
         └─ YES → <lang>-<action>-?
                  │
                  Is this rule repo-specific?
                  ├─ NO  → <lang>-<action>-x
                  └─ YES → <lang>-<action>-<repo>
```

**Rule of thumb:** Put rules at the **most general level** where they apply. Don't duplicate rules across multiple skills.

## Guideline Skill Format

```yaml
---
name: <lang>-<action>-<repo>
description: <language> guidelines for <action> in <repo>. Applied when writing <context>.
---

# <Title>

One sentence purpose.

## When Applied

- Context 1 (e.g., "Writing Rust test files")
- Context 2 (e.g., "Files in tests/ directory")

## Rules

### <Category>

**Rule name.** Brief explanation.

```<lang>
// ✅ DO
good_example();

// ❌ DON'T
bad_example();
```

### <Another Category>

...
```

## Writing Effective Rules

**Be specific, not vague:**
```
✅ "Use expect() with descriptive message instead of unwrap() in tests"
❌ "Handle errors properly"
```

**Show code, not prose:**
```
✅ Show ✅/❌ examples with actual code
❌ Write paragraphs explaining what to do
```

**One rule per concern:**
```
✅ "Prefer &str over String in function parameters"
✅ "Use into() for ownership transfer"
❌ "Handle strings correctly" (too broad)
```

**Include the WHY when non-obvious:**
```
✅ "Use #[must_use] on Result-returning functions — prevents silent error drops"
❌ "Use #[must_use] on functions" (why? when?)
```

**Only actionable content:**
```
✅ The pattern to avoid (with code)
✅ The correct pattern (with code)
✅ How to spot it during review
❌ "Why this is hard to spot" (not actionable)
❌ Historical background (trivia)
❌ Venting about library authors
❌ "This caused production issues" (emotional, not guidance)
```

**Skills must be self-contained:**
```
✅ Include all necessary context within the skill itself
❌ Reference local files (~/Documents/..., ./docs/...)
❌ Reference URLs that may change or become unavailable
```

Skills are loaded dynamically and may be used across different machines/contexts. External references break portability.

## Evolving Existing Guidelines

When updating a skill:

1. **Read existing rules** to avoid duplication
2. **Find the right section** or create new category
3. **Add rule with ✅/❌ examples**
4. **Check for conflicts** with more/less specific skills

**Avoid duplication across specificity levels:**
- If `rust-x` says "no unwrap", don't repeat in `rust-testing`
- Only add to `rust-testing` if tests have a **different** rule

## Creating New Skills

When a skill doesn't exist yet:

1. **Determine the name** using 3-part convention
2. **Create directory:** `mkdir -p ~/.config/opencode/skills/codestyle/<name>/`
3. **Write SKILL.md** with frontmatter and rules
4. **Keep focused:** Start with 3-5 rules, expand as needed

## Quick Reference

| Part | Values |
|------|--------|
| `<language>` | `rust`, `typescript`, `python`, `go`, `x` (any) |
| `<action>` | `testing`, `benchmarks`, `examples`, `architecture`, `x` (any) |
| `<repo>` | Repo name (e.g., `cobalt`, `myproject`), `x` (any) |
