---
name: i18n-audit
description: Grep block JS, dynamic block.php, patterns, and inc/ files for i18n failures — wrong text-domain and plain echo of string literals — as defined in .claude/rules/i18n.md.
---

# i18n audit skill

## When to invoke

- User explicitly runs `/i18n-audit`.
- User asks for an i18n or translation check after writing or editing a `block.php`, pattern, or `inc/*.php` file.

## Scan paths

```
wp-content/themes/theme-fse/inc/
wp-content/themes/theme-fse/_dev/blocks/*/*.js
wp-content/themes/theme-fse/_dev/blocks/*/*.php
wp-content/themes/theme-fse/patterns/
```

## Procedure

Run the four grep passes below from the repo root. Collect every hit, annotate with the failure category, and group results by file.

### 1. `[DOMAIN]` — Wrong text-domain in a translation function

```bash
grep -rn '__(\|_e(\|_x(\|_n(\|esc_html__(\|esc_attr__(\|esc_html_e(\|esc_attr_e(' \
  --include="*.php" \
  wp-content/themes/theme-fse/inc \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns
```

For each hit, check the text-domain argument (last string argument). Flag any value that is **not** `studioval-boilerplate`.

### 2. `[BLOCK-DOMAIN]` — Wrong text-domain in block editor JS

Blocks register client-side (no `block.json`); their `title`, `description`, `keywords` go through
`__()` from `@wordpress/i18n`. Grep the block JS for translation calls:

```bash
grep -rn '__(' \
  wp-content/themes/theme-fse/_dev/blocks/*/*.js
```

For each hit, check the text-domain argument. Flag any value that is **not** `studioval-boilerplate`,
and any user-visible `title` / `description` / `keywords` passed as a bare string (not wrapped in `__()`).

### 3. `[ECHO]` — Plain `echo` of a string literal (potential untranslated string)

```bash
grep -rn "echo ['\"]" \
  --include="*.php" \
  wp-content/themes/theme-fse/inc \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns
```

Flag every hit where the echoed string contains alphabetic characters (i.e. is a user-visible string, not a tag or symbol). Exclude lines where the echo is wrapped in an escaping function (`esc_html`, `esc_attr`, etc.) that also handles translation.

## Output format

```
## i18n audit — <N> findings

### ❌ Failures
- <file>:<line> — [CAT] <issue> → <fix>

### ✅ Clean
- <file> — no findings

<N> failure(s) across <M> file(s). Fix before shipping.
```

Category labels: `[DOMAIN]`, `[BLOCK-DOMAIN]`, `[ECHO]`, `[ECHO-FIELD-UNSAFE]`.

If zero findings: output `✅ All clear — 0 i18n failures found.`

## Reference

Full i18n rules: `.claude/rules/i18n.md`
