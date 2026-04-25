---
name: block-audit
description: Read every block.json under _dev/blocks/ and report missing or incorrect mandatory fields as defined in .claude/rules/blocks.md — schema, apiVersion, name namespace, textdomain, category, acf.renderTemplate, and asset paths.
---

# Block audit skill

## When to invoke

- User explicitly runs `/block-audit`.
- User asks for a block check after adding or editing a block folder.
- After running `npm run make-block` to verify the scaffold is correct.

## Scan path

```
wp-content/themes/theme-fse/_dev/blocks/*/block.json
```

Exclude `_dev/blocks/block/block.json` (the skeleton template — not a real block).

## Procedure

For each `block.json` found, read its content and check the following fields. Flag every violation with its category label.

### 1. `[SCHEMA]` — Missing or wrong `$schema`

Expected: `"$schema": "https://schemas.wp.org/trunk/block.json"` as the first key.

### 2. `[API-VER]` — Wrong or missing `apiVersion`

Expected: `"apiVersion": 3`.

### 3. `[NAMESPACE]` — Block name not prefixed with `studioval/`

Expected: `"name": "studioval/<slug>"`. Flag any name that does not start with `studioval/`.

### 4. `[DOMAIN]` — Missing or wrong `textdomain`

Expected: `"textdomain": "studioval-boilerplate"`. Flag missing field or any other value.

### 5. `[CATEGORY]` — Missing or wrong `category`

Expected: `"category": "studioval"`. Flag missing field or core WP categories (`text`, `media`, `design`, `widgets`, `theme`, `embed`).

### 6. `[ACF]` — Missing `acf.renderTemplate`

Expected: `"acf": { "renderTemplate": "block.php" }`. Flag if `acf` key is absent or `renderTemplate` is not `"block.php"`.

### 7. `[ASSET]` — Missing `style` or `script` asset path

Expected:
- `"style": "file:../../../dist/blocks/<slug>/block.css"`
- `"script": "file:../../../dist/blocks/<slug>/block.js"` (may legitimately be absent for blocks with no frontend JS — report as a warning, not a blocking failure)

Flag if `style` is absent. Flag as warning if `script` is absent.

## Output format

```
## Block audit — <N> findings

### ❌ Blocking
- <file> — [CAT] <issue> → <fix>

### ⚠️ Warnings
- <file> — [CAT] <issue>

### ✅ Clean
- <file> — all mandatory fields present

<N> finding(s) across <M> block(s).
```

Category labels: `[SCHEMA]`, `[API-VER]`, `[NAMESPACE]`, `[DOMAIN]`, `[CATEGORY]`, `[ACF]`, `[ASSET]`.

If zero findings: output `✅ All clear — all block.json files are valid.`

## Reference

Full block authoring rules: `.claude/rules/blocks.md`
