# Custom Blocks

Custom blocks in this theme are **native Gutenberg blocks** registered **client-side** in the editor JS — no `block.json`, no `register_block_type()`. The block can be **static** (markup saved in post content via `save()`) or **dynamic** (markup rendered server-side from a PHP template).

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

```text
_dev/blocks/{block-slug}/
├── {block-slug}.js              # Editor: registerBlockType + edit + save
├── {block-slug}.scss            # Shared styles (editor + front-end)
├── {block-slug}-editor.scss     # Editor-only styles
├── {block-slug}-frontend.js     # Front-end script
└── {block-slug}.php             # Optional — only for dynamic blocks
```

Webpack compiles each block to `dist/blocks/{block-slug}/` with normalised names: `block.js`, `block.css`, `block-editor.css`, `block-frontend.js`. [`inc/blocks.php`](../wp-content/themes/theme-fse/inc/blocks.php) globs `dist/blocks/*/` and enqueues whichever bundles exist — editor-only assets via `enqueue_block_editor_assets`, shared styles and front-end JS via `wp_enqueue_scripts`. No manual registration list to maintain.

## `{block-slug}.js`

The block is registered entirely in JS — `title`, `description`, `category`, `icon`, `attributes`, `supports`, and `edit`/`save` are all passed to `registerBlockType`. The `@wordpress/*` imports resolve to globals at runtime via Webpack `externals`, so nothing is bundled.

```js
import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps, RichText } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

function Edit({ attributes, setAttributes }) {
	const blockProps = useBlockProps();

	return (
		<div {...blockProps}>
			<RichText
				tagName="p"
				value={attributes.content}
				onChange={(content) => setAttributes({ content })}
				placeholder={__('Saisir le contenu…', 'studioval-boilerplate')}
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

registerBlockType('studioval/my-block', {
	apiVersion: 3,
	title: __('My Block', 'studioval-boilerplate'),
	description: __('Un bloc personnalisé nommé my-block.', 'studioval-boilerplate'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['my-block'],
	supports: { align: true, anchor: true, html: false },
	attributes: { content: { type: 'string', default: '' } },
	edit: Edit,
	save: Save,
});
```

For a **dynamic** block, `Save` returns `null` and the markup comes from `{block-slug}.php`:

```js
const Save = () => null;

registerBlockType('studioval/my-block', {
	// …
	render: 'file:./my-block.php',
	edit: Edit,
	save: Save,
});
```

The `render: 'file:./{slug}.php'` field tells the block render pipeline where to find the server-side template.

> **Important:** do not `import` the SCSS files from the JS. Webpack discovers `{slug}.scss`, `{slug}-editor.scss`, and `{slug}-frontend.js` independently and compiles them to separate bundles so editor-only styles stay out of the front-end.

## `{block-slug}.php` (dynamic blocks only)

```php
<?php
/**
 * Block render template — My Block.
 *
 * @var array    $attributes Block attributes.
 * @var string   $content    Inner block content (empty for blocks without InnerBlocks).
 * @var WP_Block $block      Block instance.
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$content_attr = isset( $attributes['content'] ) ? $attributes['content'] : '';

$wrapper_attributes = get_block_wrapper_attributes();
?>
<div <?php echo wp_kses_data( $wrapper_attributes ); ?>>
	<p><?php echo esc_html( $content_attr ); ?></p>
</div>
```

**Escaping rules — no exceptions:**

| Output type            | Function          |
| ---------------------- | ----------------- |
| Plain text             | `esc_html()`      |
| HTML attributes        | `esc_attr()`      |
| URLs (href, src)       | `esc_url()`       |
| Rich content / WYSIWYG | `wp_kses_post()`  |

`get_block_wrapper_attributes()` returns a pre-built attribute string that includes the block's class names (including `wp-block-studioval-{slug}`), align/anchor/style attributes, and any custom `className` from the editor. Pass it through `wp_kses_data()` on output.

## `{block-slug}.scss` and `{block-slug}-editor.scss`

```scss
.wp-block-studioval-my-block {
	// Shared styles (editor + front-end) using nested BEM.

	&__heading {
		font-size: var(--wp--preset--font-size--x-large);
	}
}
```

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.wp-block-studioval-{slug}` — no global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over hardcoded values when the source is `theme.json`.
- The `-editor` file holds overrides that should not leak to the front-end (placeholder backgrounds, inserter previews, etc.).

## `{block-slug}-frontend.js`

Loads on the front-end only — both static and dynamic blocks get one so any interactive behaviour has a clear home. Stays empty (just a placeholder `console.log`) until you need it.

## After scaffolding

1. Run `npm run dev` to pick up the new Webpack entries.
2. Insert the block in the editor; verify `edit` and front-end render.
3. Run `composer lint` and `npm run lint:css` + `npm run lint:js` to confirm clean.

## Authoring checklist

- [ ] Folder under `_dev/blocks/` with `{slug}.js`, `{slug}.scss`, `{slug}-editor.scss`, `{slug}-frontend.js` (and `{slug}.php` for dynamic blocks)
- [ ] `registerBlockType` namespace is `studioval/{slug}`
- [ ] `attributes` declared in `registerBlockType` covers every piece of data the block stores
- [ ] Static block: `Save` returns markup. Dynamic block: `Save = () => null` and `render: 'file:./{slug}.php'`
- [ ] Named `Edit` / `Save` functions (capitalised) so hooks linting passes
- [ ] PHP template (dynamic) escapes all output and uses `get_block_wrapper_attributes()`
- [ ] Styles use BEM and are scoped to `.wp-block-studioval-{slug}`
- [ ] Block bundles compile under `dist/blocks/{slug}/` after `npm run build` — `inc/blocks.php` picks them up automatically
