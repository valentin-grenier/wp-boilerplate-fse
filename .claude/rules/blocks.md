# Block authoring rules

See [`../BLOCKS.md`](../BLOCKS.md) for the full guide. This rule file is the quick review checklist that phpcs can't enforce.

## Folder structure

```text
_dev/blocks/{block-slug}/
├── block.json    # metadata + attributes
├── block.js      # editor script: registerBlockType + edit + save
├── block.scss    # block-scoped BEM styles
└── block.php     # optional — only for dynamic blocks
```

`inc/blocks.php` globs every `block.json` under `_dev/blocks/*/` and calls `register_block_type` on the `init` hook. No manual registration list.

## `block.json` mandatory fields

- `$schema: https://schemas.wp.org/trunk/block.json` — always first.
- `apiVersion: 3`.
- `name: studioval/{slug}` — the block namespace is the agency brand and never substituted.
- `textdomain: studioval-boilerplate`.
- `category: studioval` — register new categories in `inc/block-categories.php`, don't silently reuse WP core ones.
- `editorScript: file:../../../dist/blocks/{slug}/block.js`.
- `style: file:../../../dist/blocks/{slug}/block.css`.
- `attributes`: declare every piece of data the block stores.
- `render: file:./block.php` — **only for dynamic blocks**, otherwise omit.

## `block.js`

- Use named `Edit` / `Save` functions (capitalised) so the `react-hooks/rules-of-hooks` lint passes when calling `useBlockProps()`.
- Static block: `save` returns markup. Dynamic block: `save: () => null` and `render` set in `block.json`.
- Use the `wp.blocks` / `wp.blockEditor` / `wp.i18n` globals — no ES `import` needed.

## `block.php` (dynamic blocks only)

- Escape every output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- Never `echo` raw values from `$attributes`.
- ABSPATH guard at the top (defence-in-depth — WP normally loads the template via `register_block_type` rendering, but the guard costs nothing).
- Use `get_block_wrapper_attributes()` for the wrapper element.
- PHPDoc `@var` for `$attributes`, `$content`, `$block` (template variables, not function params).

## `block.scss`

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.wp-block-studioval-{slug}`. No global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over SCSS variables when the value comes from `theme.json`.

## Scaffolding

```bash
cd wp-content/themes/theme-fse/_dev
npm run make-block {slug}
# Prompts: 1) Static or 2) Dynamic.
```

Always confirm text-domain, namespace, category after scaffolding.

## After adding a block

- `npm run dev` to rebuild.
- Insert a test instance in the editor; verify edit + frontend render.
- `composer lint` + `npm run lint:css` + `npm run lint:js` clean.
