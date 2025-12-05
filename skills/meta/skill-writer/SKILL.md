---
name: skill-writer
description: Creates OpenCode skills with proper format. Use when asked to write a skill, create a SKILL.md, or help author skills. Ensures correct YAML frontmatter, markdown structure, and activation-optimized descriptions.
---

# Skill Writer

Write OpenCode skills that follow proper format and activate reliably.

## Skill File Structure

Skills are organized by category:

```
~/.config/opencode/skills/
├── codestyle/                 # Code style guidelines
│   ├── rust-x/SKILL.md
│   └── rust-testing/SKILL.md
├── domain/                    # Domain knowledge
│   └── rust-eventsourcing/SKILL.md
└── meta/                      # Meta-skills (writers)
    ├── code-guideline-writer/SKILL.md
    ├── skill-writer/SKILL.md
    └── linear/SKILL.md
```

Each skill directory contains:

```
skill-name/
├── SKILL.md              # Required - main instructions
└── reference/            # Optional - supporting docs
    └── detailed-guide.md
```

## Skill Categories

| Category | Purpose | Writer Skill | Naming |
|----------|---------|--------------|--------|
| Code style | Code style rules, lints, conventions | `code-guideline-writer` | `<lang>-<action>-<repo>` |
| Domain | Domain knowledge, patterns, concepts | `skill-writer` (this) | `<lang>-<domain>-<repo>` |
| Meta | Skills that write/manage other skills | `skill-writer` (this) | descriptive name |

**Use `x` as wildcard** for "any" (e.g., `rust-x` = all Rust code everywhere).

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: kebab-case-name
description: What this skill does. Use when [specific triggers]. Handles [specific scenarios].
---
```

**Critical rules:**
- `name`: lowercase, hyphens only, max 64 chars, use gerund form (e.g., `code-reviewing`)
- `description`: max 1024 chars, MUST include both:
  - What the skill does
  - When to activate it (trigger words/contexts)

### Body Structure

```markdown
# Skill Title

One sentence purpose.

## When To Use

- Specific trigger scenario 1
- Specific trigger scenario 2

## Core Instructions

### Phase 1: [Name]

Imperative prose. **Bold** critical points.

### Phase 2: [Name]

Next phase...

## Patterns

### ✅ DO: Pattern Name
[Good example with code]

### ❌ DON'T: Anti-pattern
[Bad example with why it's wrong]
```

## Domain Knowledge Skills

Domain skills capture **concepts, patterns, and gotchas** rather than style rules.

### Structure Difference

| Code Style | Domain Knowledge |
|------------|------------------|
| Rules with ✅/❌ examples | Concepts with definitions |
| Uniform structure | Structure varies by domain |
| "Always do X" | "X works like this because..." |
| Placement decision trees | Flow patterns / sequences |

### Domain Skill Template

```markdown
# Domain Name (Context)

One sentence describing what this domain covers.

## Evolving This Skill

**This is a living document.** When encountering new patterns:
1. Ask the user: "I learned something new - should I add it?"
2. Use `skill-writer` to maintain proper format
3. Only add non-obvious patterns that caused confusion

## When To Use

- Working with [specific tools/libraries]
- Implementing [specific patterns]
- Debugging [specific issues]

## Core Concepts

### Concept A vs Concept B

**Different purposes:**

| Concept | Purpose | When to Use |
|---------|---------|-------------|
| A | Does X | When you need X |
| B | Does Y | When you need Y |

### Key Pattern

```lang
// Example showing the pattern
```

## Testing Patterns

### Scenario Name

**Must do X before Y:**

```lang
// Step 1
// Step 2 (depends on step 1)
```

## Common Mistakes

### ❌ DON'T: Mistake description

```lang
// Wrong approach
```

### ✅ DO: Correct approach

```lang
// Right approach
```
```

### Domain Skill Checklist

Before finalizing a domain skill, verify:

- [ ] "Evolving This Skill" section exists
- [ ] Concepts explained with tables (not just prose)
- [ ] At least one testing pattern with sequencing
- [ ] Common mistakes section with ✅/❌ examples
- [ ] Description includes specific trigger words (library names, pattern names)

## Writing Rules

**Description is everything.** The description is used to decide whether to activate. Include:
- Action verbs describing capability
- Specific contexts ("when working with Rust", "when reviewing PRs")
- File types or domains handled

**Prose over rules.** Write instructions as imperative sentences, not bullet-point rules:
- ✅ "Create the component using functional patterns. **Always** include error boundaries."
- ❌ "Rule 1: Use functional patterns. Rule 2: Include error boundaries."

**Examples beat explanations.** A 50-token code example teaches better than 150 tokens of prose:
- ✅ Show input → output pairs
- ❌ Explain what the output should look like

**Assume intelligence.** Don't explain:
- Basic programming concepts
- Standard library usage
- Common patterns

Only include what genuinely isn't known (domain-specific patterns, project conventions, your preferences).

**Keep it short.** Target 150-300 lines. Max 500 lines. If longer, split into reference files.

## Length Guidelines

| Content Type | Lines |
|--------------|-------|
| Frontmatter | 4-6 |
| Overview | 5-10 |
| Core instructions | 100-200 |
| Examples/patterns | 50-100 |
| **Total** | **150-300** |

## Activation Optimization

Skills activate based on description matching. To improve reliability:

1. **Include trigger phrases** users would naturally say:
   - "review this code" → include "code review" in description
   - "help with Rust" → include "Rust development" in description

2. **Be specific, not generic:**
   - ✅ "Formats SQL queries for PostgreSQL with proper indexing hints"
   - ❌ "Helps with database stuff"

3. **State the domain explicitly:**
   - ✅ "Use when writing Rust code, reviewing ownership patterns, or optimizing with zero-cost abstractions"
   - ❌ "Use for programming tasks"

## Output Format

When creating a skill, output:

1. The complete `SKILL.md` content in a code block
2. The full directory path: `~/.config/opencode/skills/<category>/<skill-name>/SKILL.md`
3. Any reference files needed (in separate code blocks)

## Quick Reference

| Element | Format |
|---------|--------|
| Headers | `##` for sections, `###` for subsections |
| Emphasis | `**bold**` for critical points |
| Code | Fenced blocks with language tags |
| Good/bad | `### ✅ DO:` and `### ❌ DON'T:` |
| Tables | For quick lookups only |
