# Block authoring rules

See [`../BLOCKS.md`](../BLOCKS.md) for the full guide. This rule file is the quick review checklist that phpcs can't enforce.

## Folder structure

```text
_dev/blocks/{block-slug}/
├── block.json    # metadata
├── block.php     # ACF server-render template
├── block.js      # editor script (often empty for ACF blocks)
└── block.scss    # block-scoped BEM styles
```

`inc/block-acf.php` globs every `block.json` under `_dev/blocks/*/` and calls `register_block_type`. No manual registration list.

## `block.json` mandatory fields

- `$schema: https://schemas.wp.org/trunk/block.json` — always first.
- `apiVersion: 3`.
- `name: studioval/{slug}` — the block namespace is the agency brand and never substituted.
- `textdomain: studioval-boilerplate`.
- `category: studioval` — register new categories in `inc/block-categories.php`, don't silently reuse WP core ones.
- `acf.renderTemplate: block.php`.
- `style` / `script`: `file:../../../dist/blocks/{slug}/block.{css,js}`.

## `block.php`

- Escape every output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- Never `echo get_field( 'x' )` directly.
- ABSPATH guard at the top (defence-in-depth — WP normally loads the template via `register_block_type` rendering, but the guard costs nothing).
- PHPDoc `@param` / `@var` blocks for `$block`, `$content`, `$is_preview`, `$post_id`.

## `block.scss`

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.{block-slug}`. No global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over SCSS variables when the value comes from `theme.json`.

## Scaffolding

```bash
cd wp-content/themes/theme-fse/_dev
npm run make-block
```

The script seeds the 4 files from `_dev/blocks/block/` with placeholders substituted. Always confirm text-domain, namespace, category afterwards.

## After adding a block

- Define ACF fields in `wp-admin → Custom Fields → Field Groups`, targeting block `studioval/{slug}`.
- Export field group as PHP or JSON into the block folder (commit it).
- `npm run dev` to rebuild.
- Insert a test instance in the editor; verify preview + frontend render.
- `composer lint` + `npm run lint:css` + `npm run lint:js` clean.
