---
description: Show code cleanly with line numbers and collapsed context
---

# Show Code Cleanly

Show code for: `$ARGUMENTS`

## Instructions

**DO NOT** interpret or paraphrase. **SHOW** the actual code.

1. Read the relevant file(s)
2. **Be laser-focused** - show ONLY the lines directly relevant to `$ARGUMENTS`
3. Collapse everything else with `⋮` (two lines)
4. Always include line numbers (indented)
5. Keep it **tight** - if showing 50 lines, you're showing too much

## Single File Format

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 **`<relative_path>`**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```rust
   42  fn relevant_function() {
   43      let important_setup = something();
    ⋮
    ⋮
   67      // THE KEY PART
   68      let result = key_operation()
   69          .with_important_detail()
   70          .await;
    ⋮
    ⋮
   85  }
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## When Comparing Two Implementations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔀 **COMPARING: `<topic>`**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**A:** `<name>` — `<file>`

```rust
   42  let wrapper = async fn #old_ident() {
   43      #test_fn  // embeds original function
    ⋮
    ⋮
   51      let res = #new_ident()
   52          .instrument(span)
   53          .await;
```

────────────────────────────────────────────────────────────────────────────────

**B:** `<name>` — `<file>`

```rust
   35  async #sig_without_async {
   36      async #fn_block  // wraps body directly
   37          .instrument(span)
   38          .await
   39  }
```

────────────────────────────────────────────────────────────────────────────────

**Key Differences:**
- A embeds & calls function, B wraps body directly
- A always expects async inner fn, B works with sync too

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Rules

- **Tight**: 10-20 lines max, collapse aggressively with `⋮`
- **Focused**: Only lines directly relevant to `$ARGUMENTS`
- **Numbered**: Always include line numbers (indented)
- **Actual**: Show real code, not paraphrased
- **Brief**: Notes come AFTER, keep them short

## Follow-up: Expand

User can say:
- `expand` → show more context around all collapsed sections
- `expand <line>` → expand around specific line number

When expanding, mark focus lines with `←` at the end:

```rust
   37      let fn_attrs = &input_fn.attrs;
   38      let fn_vis = &input_fn.vis;
   39      let mut sig_without_async = fn_sig.clone();    // ← THE KEY PART
   40      sig_without_async.asyncness = None;            // ←
   41
   42      let expanded = quote! {
```

`←` at end of line = focus. Everything else is context.
