---
name: block-audit
description: Read every block source folder under _dev/blocks/ and report missing or incorrect mandatory fields in the registerBlockType call as defined in .claude/rules/blocks.md — namespace, textdomain on i18n strings, category, attributes, edit/save shape, and the render field for dynamic blocks.
---

# Block audit skill

## When to invoke

- User explicitly runs `/block-audit`.
- User asks for a block check after adding or editing a block folder.
- After running `npm run make-block` to verify the scaffold is correct.

## Scan path

```
wp-content/themes/theme-fse/_dev/blocks/*/
```

For each block folder, read the editor JS file (`{slug}.js`) and check the `registerBlockType` call.

## Procedure

For each block, flag every violation with its category label.

### 1. `[NAMESPACE]` — Wrong block name

Expected: `registerBlockType('studioval/{slug}', …)`. Flag any namespace that is not `studioval/`.

### 2. `[DOMAIN]` — Missing text-domain on `__()` calls

Every `__('…')` in `title`, `description`, `keywords` must include `'studioval-boilerplate'` as the second arg.

### 3. `[CATEGORY]` — Wrong category

Expected: `category: 'studioval'`. Flag missing field or core WP categories (`text`, `media`, `design`, `widgets`, `theme`, `embed`).

### 4. `[ATTRIBUTES]` — Missing attributes declaration

If the `Edit` function reads from `attributes.X`, `X` must be declared in the `attributes` object passed to `registerBlockType`. Flag any attribute used in `Edit`/`Save` that is not declared.

### 5. `[EDIT-SAVE]` — Inline arrow functions instead of named components

Expected: `edit: Edit` and `save: Save` referring to named functions. Flag inline arrow functions like `edit: ({ attributes }) => …` (these break `react-hooks/rules-of-hooks` for `useBlockProps`).

### 6. `[RENDER]` — Dynamic block missing `render`, or static block with stray `render`

If a `{slug}.php` file exists in the folder, the JS must include `render: 'file:./{slug}.php'` and `Save` must be `() => null`. Conversely, if `render` is set, the PHP file must exist.

### 7. `[SCSS-IMPORT]` — JS importing SCSS files

The JS file should not contain `import './{slug}.scss'` or similar. Webpack discovers SCSS independently. Flag any such import.

## Output format

```
## Block audit — <N> findings

### ❌ Blocking
- <file> — [CAT] <issue> → <fix>

### ⚠️ Warnings
- <file> — [CAT] <issue>

### ✅ Clean
- <slug> — all checks pass

<N> finding(s) across <M> block(s).
```

Category labels: `[NAMESPACE]`, `[DOMAIN]`, `[CATEGORY]`, `[ATTRIBUTES]`, `[EDIT-SAVE]`, `[RENDER]`, `[SCSS-IMPORT]`.

If zero findings: output `✅ All clear — all blocks pass the checklist.`

## Reference

Full block authoring rules: `.claude/rules/blocks.md`
