# ACF Blocks

All custom blocks in this theme are ACF-backed server-rendered blocks — no React required. The block editor displays a live PHP preview via `acf.mode: "preview"`, so authoring stays close to PHP and the ACF field UI.

## Scaffold a new block

```bash
cd wp-content/themes/your-project-slug/_dev
npm run make-block
```

The script prompts for slug, title, description, icon, and category, then creates a complete block folder from the template.

## File structure

Each block lives in its own folder under `_dev/blocks/`:

```
_dev/blocks/{block-slug}/
├── block.json    # WP block metadata — auto-discovered, no manual registration
├── block.php     # Server-render template — reads ACF fields, outputs HTML
├── block.js      # Editor-side script — usually empty for ACF blocks
└── block.scss    # Block-scoped BEM styles
```

`inc/block-acf.php` globs every `block.json` under `_dev/blocks/*/` and registers each via `register_block_type()`. No manual registration list to maintain.

## block.json

```json
{
    "$schema": "https://schemas.wp.org/trunk/block.json",
    "apiVersion": 3,
    "name": "studioval/my-block",
    "title": "My Block",
    "description": "Short description.",
    "textdomain": "studioval-boilerplate",
    "style": ["file:../../../dist/blocks/my-block/block.css"],
    "script": ["file:../../../dist/blocks/my-block/block.js"],
    "category": "studioval",
    "icon": "screenoptions",
    "keywords": ["studio"],
    "acf": {
        "mode": "preview",
        "renderTemplate": "block.php"
    },
    "supports": {
        "anchor": false,
        "spacing": { "margin": false, "padding": false }
    }
}
```

Key fields:

| Field | Value | Note |
|-------|-------|------|
| `name` | `studioval/{slug}` | Namespace is always `studioval/` — never changes between projects |
| `textdomain` | `studioval-boilerplate` | Substituted to your project slug by `bin/setup.sh` |
| `category` | `studioval` | Registered in `inc/block-categories.php` — do not use WP core categories |
| `acf.renderTemplate` | `block.php` | Must be in the same folder as `block.json` |
| `style` / `script` | `file:../../../dist/blocks/{slug}/…` | Points to the compiled output under `dist/` |

## block.php

```php
<?php
if ( ! defined( 'ABSPATH' ) ) { exit; }

/**
 * @var array  $block      Block settings and attributes.
 * @var string $content    Inner block content (if any).
 * @var bool   $is_preview True when rendering inside the editor.
 * @var int    $post_id    Current post ID.
 */

$heading = get_field( 'heading' ) ?: '';

$class = 'my-block';
if ( ! empty( $block['className'] ) ) {
    $class .= ' ' . $block['className'];
}
?>
<section class="<?php echo esc_attr( $class ); ?>">
    <?php if ( $heading ) : ?>
        <h2 class="my-block__heading"><?php echo esc_html( $heading ); ?></h2>
    <?php endif; ?>
</section>
```

**Escaping rules — no exceptions:**

| Output type | Function |
|-------------|----------|
| Plain text | `esc_html()` |
| HTML attributes | `esc_attr()` |
| URLs (href, src) | `esc_url()` |
| Rich content / WYSIWYG | `wp_kses_post()` |

Never `echo get_field( 'x' )` directly — always assign to a variable and escape on output.

## block.scss

```scss
@use '../../scss/abstracts/variables' as *;

.my-block {
    &__heading {
        font-size: var(--wp--preset--font-size--x-large);
    }
}
```

- BEM only: `.block`, `.block__element`, `.block--modifier`.
- Scope everything to `.{block-slug}` — no global selectors.
- Prefer `var(--wp--preset--color--x)` / `var(--wp--custom--spacing--x)` over hardcoded values when the source is `theme.json`.

## block.js

For ACF server-rendered blocks this file is typically empty — the editor reuses `block.php` via `acf.mode: "preview"`. Keep the file so Webpack auto-detects the entry point.

## After scaffolding

1. Define ACF fields in **wp-admin → Custom Fields → Field Groups**, targeting `studioval/{slug}`.
2. Export the field group as PHP or JSON into the block folder and commit it.
3. Run `npm run dev` to pick up the new Webpack entry.
4. Insert a test instance in the editor; verify the preview and frontend render.
5. Run `composer lint` and `npm run lint:css` + `npm run lint:js` to confirm clean.

## Authoring checklist

- [ ] Folder under `_dev/blocks/` with all 4 files
- [ ] `block.json` `name` uses the `studioval/` namespace
- [ ] `block.json` `textdomain` is `studioval-boilerplate`
- [ ] `block.json` `category` is `studioval`
- [ ] `block.php` escapes all output — no raw `echo get_field(...)`
- [ ] Styles use BEM and are scoped to `.{block-slug}`
- [ ] Block appears in editor after `npm run build` without touching `inc/block-acf.php`
