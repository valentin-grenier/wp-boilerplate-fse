# Block authoring

How custom blocks work in this theme. All blocks are **native Gutenberg blocks** registered from a `block.json` manifest. Each block can be **static** (markup persisted via `save()`) or **dynamic** (markup rendered server-side from a PHP template).

## Directory contract

```text
wp-content/themes/theme-fse/_dev/blocks/{block-slug}/
├── block.json    # Block manifest — required, auto-discovered
├── block.js      # Editor script: registerBlockType + edit + save
├── block.scss    # Block-scoped styles — compiled into dist/
└── block.php     # Optional — only for dynamic blocks (referenced by `render` in block.json)
```

Every folder under `_dev/blocks/` that contains a `block.json` becomes a registered block. Registration is handled by [`inc/blocks.php`](../wp-content/themes/theme-fse/inc/blocks.php), which globs the directory and calls `register_block_type( $block_json_file )` on each, hooked on `init`.

There is no manual registration list to keep in sync.

The reference block at `_dev/blocks/block/` is a working static block — use it as the canonical example.

## `block.json` — current template

Literal content of `_dev/blocks/block/block.json` at HEAD (static block):

```json
{
  "$schema": "https://schemas.wp.org/trunk/block.json",
  "apiVersion": 3,
  "name": "studioval/block",
  "title": "Studio Val",
  "description": "Default native block for starter theme.",
  "textdomain": "studioval-boilerplate",
  "category": "studioval",
  "icon": "screenoptions",
  "keywords": ["studio"],
  "editorScript": "file:../../../dist/blocks/block/block.js",
  "style": "file:../../../dist/blocks/block/block.css",
  "attributes": {
    "content": {
      "type": "string",
      "default": ""
    }
  },
  "supports": {
    "anchor": false,
    "inserter": true,
    "spacing": {
      "margin": false,
      "padding": false
    }
  }
}
```

For a **dynamic** block, add a `render` field pointing to the PHP template:

```json
"render": "file:./block.php"
```

**Conventions:**

- `$schema` — always `https://schemas.wp.org/trunk/block.json`. Powers editor autocomplete.
- `apiVersion: 3` — opt in to WP 6.3+ behaviour (iframed editor, theme.json support per block).
- `name` — `studioval/{slug}`. The block namespace is the agency brand and stays constant across client installs.
- `textdomain` — `studioval-boilerplate`. Required for `ddev wp i18n make-pot` to catch `title`, `description`, and `keywords` strings.
- `category` — `studioval`, the theme's own category registered by [`inc/block-categories.php`](../wp-content/themes/theme-fse/inc/block-categories.php).
- `editorScript` — points to the compiled JS under `dist/blocks/{slug}/block.js`.
- `style` — compiled CSS, loaded on both editor and front-end.
- `attributes` — declare every piece of data the block stores. `edit`/`save` receive them via `attributes`.
- `render` (dynamic only) — `file:./block.php`, resolved relative to `block.json`.

## `block.js`

Registers the block in the editor. Uses WordPress globals (`wp.blocks`, `wp.blockEditor`, `wp.i18n`) — no ES `import` needed; they are guaranteed to be available in the editor context. JSX compiles via `@wordpress/element` (configured in `_dev/babel.config.json`).

Pattern from `_dev/blocks/block/block.js`:

```js
const { registerBlockType } = wp.blocks;
const { useBlockProps, RichText } = wp.blockEditor;
const { __ } = wp.i18n;

function Edit({ attributes, setAttributes }) {
  const blockProps = useBlockProps();

  return (
    <div {...blockProps}>
      <RichText
        tagName="p"
        value={attributes.content}
        onChange={(content) => setAttributes({ content })}
        placeholder={__("Saisir le contenu…", "studioval-boilerplate")}
      />
    </div>
  );
}

function Save({ attributes }) {
  const blockProps = useBlockProps.save();

  return (
    <div {...blockProps}>
      <RichText.Content tagName="p" value={attributes.content} />
    </div>
  );
}

registerBlockType("studioval/block", {
  edit: Edit,
  save: Save,
});
```

**Why named `Edit` / `Save` functions instead of inline arrows?** The `react-hooks/rules-of-hooks` ESLint rule only recognises hooks (`useBlockProps`) inside components whose name starts with a capital letter. Inline arrow functions assigned to `edit:` / `save:` trip the lint.

For a **dynamic** block, `save` returns `null` and the markup comes from `block.php`:

```js
registerBlockType("studioval/my-block", {
  edit: Edit,
  save: () => null,
});
```

## `block.php` (dynamic blocks only)

```php
<?php
if ( ! defined( 'ABSPATH' ) ) { exit; }

/**
 * @var array    $attributes Block attributes.
 * @var string   $content    Inner block content (empty for blocks without InnerBlocks).
 * @var WP_Block $block      Block instance.
 */

$content_attr = $attributes['content'] ?? '';

$wrapper_attributes = get_block_wrapper_attributes();
?>
<div <?php echo wp_kses_data( $wrapper_attributes ); ?>>
	<p><?php echo esc_html( $content_attr ); ?></p>
</div>
```

`block.php` files are included from `register_block_type` rendering, never reached via direct HTTP. Add the `ABSPATH` guard anyway — defence-in-depth, costs nothing, consistent with all other templates.

`get_block_wrapper_attributes()` returns a pre-escaped attribute string that includes the block's class (`wp-block-studioval-{slug}`), align/anchor/style, and any custom `className` from the editor.

**Escaping rules (every output):**

- `esc_html()` for text.
- `esc_attr()` for HTML attributes.
- `esc_url()` for URLs (href, src).
- `wp_kses_post()` for rich content (WYSIWYG, RichText).

**Never** `echo` raw values from `$attributes` — always run them through an escape function.

## `block.scss`

```scss
.wp-block-studioval-block {
  // Block-scoped styles using nested BEM.

  &__heading {
    font-size: var(--wp--preset--font-size--x-large);
  }
}
```

BEM naming. Avoid global selectors; scope to `.wp-block-studioval-{slug}`.

## Scaffolding a new block

```bash
cd wp-content/themes/theme-fse/_dev
npm run make-block my-block
# Prompts: 1) Static or 2) Dynamic.
```

After scaffolding:

1. `npm run dev` to pick up the new Webpack entry.
2. Insert the block in a test page; verify editor edit and frontend render.
3. `npm run lint:js` + `npm run lint:css` + `composer lint` clean.

## Authoring checklist (code review)

- [ ] Folder under `_dev/blocks/` with `block.json`, `block.js`, `block.scss` (and `block.php` for dynamic blocks).
- [ ] `block.json` `name` uses the `studioval/` namespace.
- [ ] `block.json` declares `attributes` for every piece of data the block stores.
- [ ] Static block: `save()` returns markup. Dynamic block: `save: () => null` and `render: file:./block.php` in `block.json`.
- [ ] `block.js` uses named `Edit` / `Save` functions (capitalised) so hooks linting passes.
- [ ] PHP template (dynamic) opens with ABSPATH guard and escapes all output.
- [ ] PHP template (dynamic) uses `get_block_wrapper_attributes()` for the wrapper.
- [ ] Styles use BEM and are scoped to `.wp-block-studioval-{slug}`.
- [ ] Block appears after `npm run build` without touching `inc/blocks.php`.
