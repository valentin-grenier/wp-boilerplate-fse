# Block authoring

How custom blocks work in this theme. All blocks are ACF-backed server-rendered blocks, not JS-first
blocks. This keeps authoring close to PHP and leverages ACF's field UI.

## Directory contract

```
wp-content/themes/theme-fse/_dev/blocks/{block-slug}/
├── block.json    # WP block metadata — required, auto-discovered
├── block.php     # Server render template — receives $block, $content, $is_preview, $post_id
├── block.js      # Editor-side script — can be empty; consumed by Webpack entry auto-detection
└── block.scss    # Block-scoped styles — compiled into dist/
```

Every folder under `_dev/blocks/` that contains a `block.json` becomes a registered block.
Registration is handled by [`inc/block-acf.php`](wp-content/themes/theme-fse/inc/block-acf.php),
which globs the directory and calls `register_block_type( $block_json_dir )` on each.

There is no manual registration list to keep in sync.

## `block.json` minimum

```json
{
	"$schema": "https://schemas.wp.org/trunk/block.json",
	"apiVersion": 3,
	"name": "studioval/hero",
	"title": "Hero",
	"description": "Centered hero with heading, subheading, and CTA.",
	"category": "studioval",
	"icon": "megaphone",
	"keywords": ["hero", "cta"],
	"textdomain": "studioval-boilerplate",
	"acf": {
		"mode": "preview",
		"renderTemplate": "block.php"
	},
	"supports": {
		"align": ["wide", "full"],
		"anchor": true,
		"html": false
	},
	"style": "file:./block.css",
	"editorScript": "file:./block.js"
}
```

**Required:**

- `$schema` — always `https://schemas.wp.org/trunk/block.json`. Gives editor autocomplete and CI
  validation.
- `name` — `studioval/{slug}` (block namespace `studioval`; `setup.sh` swaps it for the client slug).
- `acf.renderTemplate` — `block.php` in the same folder.
- `textdomain` — exactly `studioval-boilerplate`. No variants.

**Category:** `studioval` is registered by [`inc/block-categories.php`](wp-content/themes/theme-fse/inc/block-categories.php).
If you need a different category, update that file; do not reuse core categories by mistake.

## `block.php` render template

```php
<?php
/**
 * Hero block render template.
 *
 * @package StudioVal\Boilerplate
 *
 * @var array $block       Block settings.
 * @var string $content    Inner content (if any).
 * @var bool $is_preview   True when rendering in the editor.
 * @var int $post_id       Current post ID.
 */
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

$heading    = get_field( 'heading' ) ?: '';
$subheading = get_field( 'subheading' ) ?: '';
$cta_text   = get_field( 'cta_text' ) ?: '';
$cta_url    = get_field( 'cta_url' ) ?: '';

$class = 'hero';
if ( ! empty( $block['className'] ) ) {
	$class .= ' ' . $block['className'];
}
?>
<section class="<?php echo esc_attr( $class ); ?>">
	<?php if ( $heading ) : ?>
		<h2 class="hero__heading"><?php echo esc_html( $heading ); ?></h2>
	<?php endif; ?>

	<?php if ( $subheading ) : ?>
		<p class="hero__subheading"><?php echo esc_html( $subheading ); ?></p>
	<?php endif; ?>

	<?php if ( $cta_text && $cta_url ) : ?>
		<a class="hero__cta" href="<?php echo esc_url( $cta_url ); ?>">
			<?php echo esc_html( $cta_text ); ?>
		</a>
	<?php endif; ?>
</section>
```

**Escaping rules (every output):**

- `esc_html()` for text.
- `esc_attr()` for HTML attributes.
- `esc_url()` for URLs (href, src).
- `wp_kses_post()` for rich content (WYSIWYG, RichText).

**Never** `echo` raw field values. phpcs blocks it.

## `block.scss`

```scss
@use '../../scss/abstracts/variables' as *;

.hero {
	&__heading {
		font-size: var(--wp--preset--font-size--x-large);
	}

	&__subheading { /* ... */ }

	&__cta { /* ... */ }
}
```

BEM naming. Avoid global selectors; scope to `.{block-slug}`.

## `block.js`

For ACF server-rendered blocks this is typically empty (the editor reuses `block.php` via
`acf.mode: "preview"`). Keep the file so Webpack auto-detects the entry; export nothing.

## Scaffolding a new block

```bash
cd wp-content/themes/theme-fse/_dev
npm run make-block
# Prompts: block slug, title, description, icon, category.
# Creates the folder with all 4 files seeded from _dev/blocks/block/ (the template folder).
```

After scaffolding:

1. Define ACF fields in `wp-admin → Custom Fields → Field Groups`. Target the block via its name
   (`studioval/{slug}`). Export to PHP or JSON inside the block folder for version control.
2. `npm run dev` to pick up the new entry.
3. Insert the block in a test page; verify editor preview and frontend render.

## Registration checklist (code review)

- [ ] Folder under `_dev/blocks/` with the 4 files.
- [ ] `block.json` has `$schema`, correct `name` namespace, `textdomain: studioval-boilerplate`.
- [ ] `block.php` opens with the `ABSPATH` guard and escapes all output.
- [ ] Styles use BEM and are scoped to `.{slug}`.
- [ ] No raw `echo get_field(...)`.
- [ ] Block appears after `npm run build` without touching `inc/block-acf.php`.
