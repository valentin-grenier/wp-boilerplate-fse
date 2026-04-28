# Block authoring

How custom blocks work in this theme. All blocks are ACF-backed server-rendered blocks, not JS-first
blocks. This keeps authoring close to PHP and leverages ACF's field UI.

## Directory contract

```text
wp-content/themes/theme-fse/_dev/blocks/{block-slug}/
├── block.json    # WP block metadata — required, auto-discovered
├── block.php     # Server render template — receives $block, $content, $is_preview, $post_id
├── block.js      # Editor-side script — can be empty; consumed by Webpack entry auto-detection
└── block.scss    # Block-scoped styles — compiled into dist/
```

Every folder under `_dev/blocks/` that contains a `block.json` becomes a registered block.
Registration is handled by [`inc/block-acf.php`](../wp-content/themes/theme-fse/inc/block-acf.php),
which globs the directory and calls `register_block_type( $block_json_dir )` on each.

There is no manual registration list to keep in sync.

Currently the only block in the repo is the template `block/` folder consumed by `make-block`.

## `block.json` — current template

This is the literal content of `_dev/blocks/block/block.json` at HEAD:

```json
{
  "$schema": "https://schemas.wp.org/trunk/block.json",
  "apiVersion": 3,
  "name": "studioval/block",
  "title": "Studio Val",
  "description": "Default ACF block for starter theme.",
  "textdomain": "studioval-boilerplate",
  "style": ["file:../../../dist/blocks/block/block.css"],
  "script": ["file:../../../dist/blocks/block/block.js"],
  "category": "studioval",
  "icon": "screenoptions",
  "keywords": ["studio"],
  "acf": {
    "mode": "preview",
    "renderTemplate": "block.php"
  },
  "supports": {
    "anchor": false,
    "jsx": false,
    "inserter": true,
    "spacing": {
      "margin": false,
      "padding": false
    }
  }
}
```

**Conventions today:**

- `$schema` — always `https://schemas.wp.org/trunk/block.json`. Powers editor autocomplete.
- `apiVersion: 3` — opt in to WP 6.3+ behaviour (iframed editor, theme.json support per block).
- `name` — `studioval/{slug}`. The block namespace is the agency brand and stays constant across
  client installs.
- `textdomain` — `studioval-boilerplate`. Required for `ddev wp i18n make-pot` to catch `title`,
  `description`, and `keywords` strings.
- `acf.renderTemplate` — `block.php` in the same folder.
- `style` / `script` — point to the compiled output under `dist/blocks/{slug}/`.
- `category` — `studioval`, the theme's own category registered by
  [`inc/block-categories.php`](../wp-content/themes/theme-fse/inc/block-categories.php).

## `block.php` render template

Pattern in use (see `_dev/blocks/block/block.php` for the literal current template):

```php
<?php
/**
 * Block render template.
 *
 * @package StudioVal\WPBoilerplate
 *
 * @var array  $block      Block settings.
 * @var string $content    Inner content (if any).
 * @var bool   $is_preview True when rendering in the editor.
 * @var int    $post_id    Current post ID.
 */

if ( ! defined( 'ABSPATH' ) ) { exit; }

$heading = get_field( 'heading' ) ?: '';

$class = 'block';
if ( ! empty( $block['className'] ) ) {
	$class .= ' ' . $block['className'];
}
?>
<section class="<?php echo esc_attr( $class ); ?>">
	<?php if ( $heading ) : ?>
		<h2 class="block__heading"><?php echo esc_html( $heading ); ?></h2>
	<?php endif; ?>
</section>
```

`block.php` files are included from `register_block_type` rendering, never reached via direct HTTP.
Add the `ABSPATH` guard anyway — defence-in-depth, costs nothing, consistent with all other templates.

**Escaping rules (every output):**

- `esc_html()` for text.
- `esc_attr()` for HTML attributes.
- `esc_url()` for URLs (href, src).
- `wp_kses_post()` for rich content (WYSIWYG, RichText).

**Never** `echo` raw field values. Lint enforcement (phpcs WordPress-Extra) is planned for Batch 2.

## `block.scss`

```scss
@use "../../scss/abstracts/variables" as *;

.block {
  &__heading {
    font-size: var(--wp--preset--font-size--x-large);
  }
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

## Authoring checklist (code review)

- [ ] Folder under `_dev/blocks/` with the 4 files.
- [ ] `block.json` `name` uses the `studioval/` namespace.
- [ ] `block.php` opens with ABSPATH guard.
- [ ] `block.php` escapes all output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- [ ] No raw `echo get_field(...)`.
- [ ] Styles use BEM and are scoped to `.{slug}`.
- [ ] Block appears after `npm run build` without touching `inc/block-acf.php`.
