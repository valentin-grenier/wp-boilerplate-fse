---
name: a11y-links-buttons
description: Grep all block.php, pattern, template, and parts files for the six WCAG/RGAA failure categories in .claude/rules/a11y.md and return a per-file report.
---

# A11y links & buttons audit skill

## When to invoke

- User explicitly runs `/a11y-links-buttons`.
- User asks for an a11y check after writing or editing a `block.php` or pattern file.

## Scan paths

```
wp-content/themes/theme-fse/_dev/blocks/*/block.php
wp-content/themes/theme-fse/patterns/
wp-content/themes/theme-fse/templates/
wp-content/themes/theme-fse/parts/
```

## Procedure

Run the six grep passes below from the repo root. Collect every hit, annotate it with the failure category, and group results by file.

### 1. `[LINK-LABEL]` — Generic link text without `aria-label`

```bash
grep -rn 'En savoir plus\|Lire plus\|Voir plus\|Lire l.article' \
  --include="*.php" --include="*.html" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns \
  wp-content/themes/theme-fse/templates \
  wp-content/themes/theme-fse/parts
```

Flag every hit. Then check the surrounding `<a>` tag (±3 lines) for an `aria-label` attribute. Only report lines where `aria-label` is absent.

### 2. `[IMG-LINK]` — Image-only `<a>` without `aria-label`

```bash
grep -rn '<a[^>]*>' \
  --include="*.php" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns
```

For each `<a>` hit, read the next 5 lines. Flag the link if it contains an `<img` and has no `aria-label` on the `<a>` tag.

### 3. `[PERMALINK]` — `the_permalink()` used directly in an `href`

```bash
grep -rn 'the_permalink()' \
  --include="*.php" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns
```

Flag every hit. Fix: replace with `esc_url( get_permalink() )`.

### 4. `[BLANK-REL]` — `target="_blank"` without `rel="noopener noreferrer"`

```bash
grep -rn 'target="_blank"' \
  --include="*.php" --include="*.html" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns \
  wp-content/themes/theme-fse/templates \
  wp-content/themes/theme-fse/parts
```

Flag every hit whose line (or immediately adjacent lines) does not include `rel="noopener noreferrer"`.

### 5. `[BTN-LABEL]` — `<button>` without visible text or `aria-label`

```bash
grep -rn '<button' \
  --include="*.php" --include="*.html" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns \
  wp-content/themes/theme-fse/templates \
  wp-content/themes/theme-fse/parts
```

For each hit read ±3 lines. Flag the button if it has no `aria-label` attribute and no visible text content (i.e. contains only an icon tag, `&times;`, or is self-closing).

### 6. `[ONCLICK]` — Non-semantic interactive elements

```bash
grep -rn 'onclick' \
  --include="*.php" --include="*.html" \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns \
  wp-content/themes/theme-fse/templates \
  wp-content/themes/theme-fse/parts
```

Flag every hit whose element is `<div`, `<span`, or `<li` (not `<button` or `<a`).

## Output format

```
## A11y audit — <N> findings

### ❌ Failures
- <file>:<line> — [CAT] <issue> → <fix>

### ✅ Clean
- <file> — no findings

<N> failure(s) across <M> file(s). Fix before shipping.
```

Category labels: `[LINK-LABEL]`, `[IMG-LINK]`, `[PERMALINK]`, `[BLANK-REL]`, `[BTN-LABEL]`, `[ONCLICK]`.

If zero findings: output `✅ All clear — 0 a11y failures found.`

## Reference

Full WCAG/RGAA rules: `.claude/rules/a11y.md`
