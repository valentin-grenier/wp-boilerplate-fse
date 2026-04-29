# Custom Blocks

Custom blocks in this theme are **native Gutenberg blocks** registered from a `block.json` manifest. The block can be **static** (markup saved in post content via `save()`) or **dynamic** (markup rendered server-side from a PHP template).

## Scaffold a new block

```bash
cd wp-content/themes/your-project-slug/_dev
npm run make-block my-block
```

The script prompts for the block type:

1. **Static** — saved in post content. The editor and the front-end share the markup returned by `save()`.
2. **Dynamic** — rendered by a PHP template at runtime. Best when output depends on PHP context (current user, query, etc.).

## File structure

Each block lives in its own folder under `_dev/blocks/`:

```
_dev/blocks/{block-slug}/
├── block.json    # Block manifest — auto-discovered, no manual registration
├── block.js      # Editor script: registerBlockType + edit + save
├── block.scss    # Block-scoped BEM styles (front-end + editor)
└── block.php     # Optional — only for dynamic blocks
```

`inc/blocks.php` globs every `block.json` under `_dev/blocks/*/` and registers each via `register_block_type()` on the `init` hook. No manual registration list to maintain.

## block.json

```json
{
  "$schema": "https://schemas.wp.org/trunk/block.json",
  "apiVersion": 3,
  "name": "studioval/my-block",
  "title": "My Block",
  "description": "Short description.",
  "textdomain": "studioval-boilerplate",
  "category": "studioval",
  "icon": "screenoptions",
  "keywords": ["studio"],
  "editorScript": "file:../../../dist/blocks/my-block/block.js",
  "style": "file:../../../dist/blocks/my-block/block.css",
  "attributes": {
    "content": {
      "type": "string",
      "default": ""
    }
  },
  "supports": {
    "anchor": false,
    "spacing": { "margin": false, "padding": false }
  }
}
```

For a **dynamic** block, add a `render` field pointing to the PHP template:

```json
"render": "file:./block.php"
```

Key fields:

| Field          | Value                                | Note                                                                     |
| -------------- | ------------------------------------ | ------------------------------------------------------------------------ |
| `name`         | `studioval/{slug}`                   | Namespace is always `studioval/` — never changes between projects        |
| `textdomain`   | `studioval-boilerplate`              | Substituted to your project slug by `bin/setup.sh`                       |
| `category`     | `studioval`                          | Registered in `inc/block-categories.php` — do not use WP core categories |
| `editorScript` | `file:../../../dist/blocks/{slug}/…` | Editor-side bundle output by Webpack                                     |
| `style`        | `file:../../../dist/blocks/{slug}/…` | Compiled CSS — loaded on both editor and front-end                       |
| `render`       | `file:./block.php` (dynamic blocks)  | Server-render template, resolved relative to `block.json`                |
| `attributes`   | Object                               | Block attributes, read in `edit`/`save` via `attributes`                 |

## block.js

Registers the block in the editor. The example block at `_dev/blocks/block/block.js` is the reference.

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

registerBlockType("studioval/my-block", {
  edit: Edit,
  save: Save,
});
```

For **dynamic** blocks, return `null` from `save` — the markup comes from `block.php`:

```js
registerBlockType("studioval/my-block", {
  edit: Edit,
  save: () => null,
});
```

The Babel config (`_dev/babel.config.json`) compiles JSX through `@wordpress/element`, so JSX works without a `React` import. WordPress globals (`wp.blocks`, `wp.blockEditor`, `wp.i18n`) are guaranteed to be available in the editor context — no ES `import` needed.

## block.php (dynamic blocks only)

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

**Escaping rules — no exceptions:**

| Output type            | Function         |
| ---------------------- | ---------------- |
| Plain text             | `esc_html()`     |
| HTML attributes        | `esc_attr()`     |
| URLs (href, src)       | `esc_url()`      |
| Rich content / WYSIWYG | `wp_kses_post()` |

`get_block_wrapper_attributes()` returns a pre-escaped attribute string that includes the block's class names (including `wp-block-studioval-{slug}`), align/anchor/style attributes, and any custom `className` from the editor.

## block.scss

```scss
.wp-block-studioval-my-block {
  // Block-scoped styles using nested BEM.

  &__heading {
    font-size: var(--wp--preset--font-size--x-large);
  }
}
```

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.wp-block-studioval-{slug}` — no global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over hardcoded values when the source is `theme.json`.

## After scaffolding

1. Run `npm run dev` to pick up the new Webpack entry.
2. Insert the block in the editor; verify edit and front-end render.
3. Run `composer lint` and `npm run lint:css` + `npm run lint:js` to confirm clean.

## Authoring checklist

- [ ] Folder under `_dev/blocks/` with `block.json`, `block.js`, `block.scss` (and `block.php` for dynamic blocks)
- [ ] `block.json` `name` uses the `studioval/` namespace
- [ ] `block.json` `textdomain` is `studioval-boilerplate`
- [ ] `block.json` `category` is `studioval`
- [ ] `block.json` declares `attributes` for any data the block stores
- [ ] Static block: `save()` returns markup. Dynamic block: `save: () => null` and `render: file:./block.php` in `block.json`
- [ ] PHP template (dynamic) escapes all output and uses `get_block_wrapper_attributes()`
- [ ] Styles use BEM and are scoped to `.wp-block-studioval-{slug}`
- [ ] Block appears in editor after `npm run build` without touching `inc/blocks.php`
