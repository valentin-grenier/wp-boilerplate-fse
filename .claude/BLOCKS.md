# Block authoring

How custom blocks work in this theme. All blocks are **native Gutenberg blocks** registered **client-side** by the editor JS — no `block.json`, no `register_block_type()`. Each block can be **static** (markup persisted via `save()`) or **dynamic** (markup rendered server-side from a PHP template).

## Directory contract

```text
wp-content/themes/theme-fse/_dev/blocks/{block-slug}/
├── {block-slug}.js              # Editor: registerBlockType + edit + save (required)
├── {block-slug}.scss            # Shared styles — loaded both in editor and front-end
├── {block-slug}-editor.scss     # Editor-only styles
├── {block-slug}-frontend.js     # Front-end behaviour (every block, static or dynamic)
└── {block-slug}.php             # PHP render template — dynamic blocks only
```

The compiled output goes to `dist/blocks/{block-slug}/` with normalised names: `block.js`, `block.css`, `block-editor.css`, `block-frontend.js`. [`inc/blocks.php`](../wp-content/themes/theme-fse/inc/blocks.php) globs `dist/blocks/*/`, then enqueues whichever bundles exist on the right action (`enqueue_block_editor_assets` or `wp_enqueue_scripts`).

There is no manual registration list to keep in sync. Drop a folder into `_dev/blocks/`, run `npm run build`, and the block appears.

## Scaffolding

```bash
cd wp-content/themes/theme-fse/_dev
npm run make-block my-block
# Prompts: 1) Static or 2) Dynamic.
```

The script creates the four (static) or five (dynamic) source files seeded with a working RichText starter.

## `{block-slug}.js`

The block is registered entirely in JS — title, description, category, icon, attributes, supports, and edit/save are all passed to `registerBlockType`. No `block.json` is needed.

Pattern from `_dev/blocks/block-example-static/block-example-static.js`:

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

The `@wordpress/*` imports resolve to globals at runtime via `webpack.common.js` `externals` (`@wordpress/blocks` → `wp.blocks`, etc.) — nothing is bundled.

**Why named `Edit` / `Save` functions instead of inline arrows?** The `react-hooks/rules-of-hooks` ESLint rule only recognises hooks (`useBlockProps`) inside components whose name starts with a capital letter. Inline arrow functions assigned to `edit:` / `save:` trip the lint.

For a **dynamic** block, `Save` returns `null` and the markup comes from `block.php`:

```js
const Save = () => null;

registerBlockType('studioval/my-block', {
	// …
	render: 'file:./my-block.php',
	edit: Edit,
	save: Save,
});
```

The `render: 'file:./{slug}.php'` field tells WordPress where to find the server-render template (resolved relative to the block JS file).

**SCSS imports.** Do not `import` the SCSS files from the JS. Webpack discovers `{slug}.scss`, `{slug}-editor.scss`, and `{slug}-frontend.js` independently and compiles them into separate output bundles so editor-only styles can be enqueued only in the editor.

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

`block.php` files are included from the block render pipeline, never reached via direct HTTP. Add the `ABSPATH` guard anyway — defence-in-depth, costs nothing.

`get_block_wrapper_attributes()` returns a pre-built attribute string with the block's class (`wp-block-studioval-{slug}`), align/anchor/style, and any custom `className` from the editor. Pass it through `wp_kses_data()` on output so phpcs is happy.

**Escaping rules (every output):**

- `esc_html()` for text.
- `esc_attr()` for HTML attributes.
- `esc_url()` for URLs (href, src).
- `wp_kses_post()` for rich content (WYSIWYG, RichText).

**Never** `echo` raw values from `$attributes` — always run them through an escape function.

## `{block-slug}.scss` and `{block-slug}-editor.scss`

```scss
.wp-block-studioval-my-block {
	// Shared styles (editor + front-end) using nested BEM.

	&__heading {
		font-size: var(--wp--preset--font-size--x-large);
	}
}
```

BEM naming. Avoid global selectors; scope to `.wp-block-studioval-{slug}`. The editor-only file holds overrides that should not leak to the front-end (e.g. inserter previews, placeholder backgrounds).

## `{block-slug}-frontend.js`

Loads on the front-end only — both static and dynamic blocks get one so any interactive behaviour has a clear home. Stays empty (just a console log placeholder) until you need it.

## Authoring checklist (code review)

- [ ] Folder under `_dev/blocks/{slug}/` with `{slug}.js`, `{slug}.scss`, `{slug}-editor.scss`, `{slug}-frontend.js` (and `{slug}.php` for dynamic blocks).
- [ ] `registerBlockType` namespace is `studioval/{slug}`.
- [ ] `attributes` declared in the `registerBlockType` call covers every piece of data the block stores.
- [ ] Static block: `Save` returns markup. Dynamic block: `Save = () => null` and `render: 'file:./{slug}.php'` is set.
- [ ] Named `Edit` / `Save` functions (capitalised) so hooks linting passes.
- [ ] PHP template (dynamic) opens with the multi-line ABSPATH guard and escapes all output.
- [ ] PHP template (dynamic) uses `get_block_wrapper_attributes()` for the wrapper.
- [ ] Styles use BEM and are scoped to `.wp-block-studioval-{slug}`.
- [ ] Block bundles compile under `dist/blocks/{slug}/` after `npm run build` — `inc/blocks.php` picks them up automatically.
