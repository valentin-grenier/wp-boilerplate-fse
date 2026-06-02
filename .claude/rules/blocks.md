# Block authoring rules

See [`../../docs/blocks.md`](../../docs/blocks.md) for the full guide. This rule file is the quick review checklist that phpcs can't enforce.

## Folder structure

```text
_dev/blocks/{slug}/
├── {slug}.js              # editor: registerBlockType + edit + save
├── {slug}.scss            # shared styles (editor + front-end)
├── {slug}-editor.scss     # editor-only styles
├── {slug}-frontend.js     # front-end script
└── {slug}.php             # optional — only for dynamic blocks
```

No `block.json`. Blocks register themselves in JS by calling `registerBlockType('studioval/{slug}', { …metadata, edit, save })`. `inc/blocks.php` enqueues the compiled bundles from `dist/blocks/{slug}/` on `enqueue_block_editor_assets` (editor) and `wp_enqueue_scripts` (front-end). No manual registration list.

## `{slug}.js` mandatory call shape

`registerBlockType('studioval/{slug}', { … })` must include:

- `apiVersion: 3`
- `title`, `description`, `keywords` wrapped in `__()` with `studioval-boilerplate` text-domain
- `category: 'studioval'` (registered in `inc/block-categories.php`, don't reuse WP core categories)
- `icon` — a string from the dashicons set or a JSX SVG component
- `attributes` — every piece of data the block stores
- `supports` — `align`, `anchor`, `html`, etc.
- `edit` — named `Edit` function (capitalised) so `react-hooks/rules-of-hooks` lint passes
- `save` — named `Save` function for static blocks; `Save = () => null` for dynamic blocks
- `render: 'file:./{slug}.php'` — **only for dynamic blocks**, otherwise omit

The `@wordpress/blocks`, `@wordpress/block-editor`, `@wordpress/i18n`, `@wordpress/element` imports resolve to globals via webpack `externals`.

**Do not import** the SCSS files from the JS — webpack discovers them as separate entries and compiles them to distinct CSS bundles.

## `{slug}.php` (dynamic blocks only)

- Multiline ABSPATH guard at the top (defence-in-depth, costs nothing).
- PHPDoc `@var` for `$attributes`, `$content`, `$block` (template variables, not function params).
- Use `get_block_wrapper_attributes()` for the wrapper element; output it through `wp_kses_data()`.
- Escape every output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- Never `echo` raw values from `$attributes`.

## `{slug}.scss` and `{slug}-editor.scss`

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.wp-block-studioval-{slug}`. No global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over SCSS variables when the value comes from `theme.json`.
- The `-editor` file holds overrides that should not leak to the front-end.

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
