---
name: i18n-audit
description: Grep all block.php, pattern, and inc/ files for i18n failures — wrong text-domain, plain echo of string literals, and block.json missing textdomain — as defined in .claude/rules/i18n.md.
---

# i18n audit skill

## When to invoke

- User explicitly runs `/i18n-audit`.
- User asks for an i18n or translation check after writing or editing a `block.php`, pattern, or `inc/*.php` file.

## Scan paths

```
wp-content/themes/theme-fse/inc/
wp-content/themes/theme-fse/_dev/blocks/*/block.php
wp-content/themes/theme-fse/_dev/blocks/*/block.json
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

### 2. `[BLOCK-DOMAIN]` — `block.json` missing or wrong `textdomain`

```bash
grep -rL '"textdomain"' \
  wp-content/themes/theme-fse/_dev/blocks/*/block.json
```

Also run:

```bash
grep -rn '"textdomain"' \
  wp-content/themes/theme-fse/_dev/blocks/*/block.json
```

Flag any `block.json` that lacks `"textdomain"` entirely, or whose value is not `"studioval-boilerplate"`.

### 3. `[ECHO]` — Plain `echo` of a string literal (potential untranslated string)

```bash
grep -rn "echo ['\"]" \
  --include="*.php" \
  wp-content/themes/theme-fse/inc \
  wp-content/themes/theme-fse/_dev/blocks \
  wp-content/themes/theme-fse/patterns
```

Flag every hit where the echoed string contains alphabetic characters (i.e. is a user-visible string, not a tag or symbol). Exclude lines where the echo is wrapped in an escaping function (`esc_html`, `esc_attr`, etc.) that also handles translation.

### 4. `[BARE-ECHO-FIELD]` — `echo get_field()` without translation wrapper

```bash
grep -rn 'echo get_field\|echo esc_html( get_field\|echo wp_kses_post( get_field' \
  --include="*.php" \
  wp-content/themes/theme-fse/_dev/blocks
```

ACF field values are user data and do not need translation functions — this check is informational only. Flag bare `echo get_field()` (no escaping) as a security smell (`[ECHO-FIELD-UNSAFE]`), not an i18n issue.

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
