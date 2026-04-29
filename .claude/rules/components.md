# Component conventions (SCSS + PHP)

These conventions apply to **all** PHP templates and their paired SCSS files: native dynamic block
render templates (`block.php`), template parts, and any other server-rendered partial.

---

## SCSS — nested BEM

Replace every flat descendant selector with SCSS nested `&` syntax.

### Target pattern

```scss
.ap-block {
  // block properties

  &.compound-modifier {
  }

  &__element {
    &:hover {
    }
    &--modifier {
    }
    child-tag {
    }
  }

  .shared-utility {
  }
}

@media screen and (max-width: $bp__mobile) {
  .ap-block {
    &__element {
    }
  }
}
```

### Exceptions — keep flat

Third-party plugin overrides (`.wpforms-*`, `.swiper-*`, etc.) must stay un-nested — nesting
changes specificity and breaks the override.

### Shared styles / mixins

When two or more components share identical CSS rules, extract them to a `@mixin` in
`_dev/scss/mixins/_shared-name.scss` and `@use` it in each component file. Do **not** add
mixin-only files to `main.scss`.

---

## PHP — security hardening

### 1. ABSPATH guard — first line of every template

```php
if ( ! defined( 'ABSPATH' ) ) { exit; }
```

### 2. Declare all values at the top with an empty-string fallback

For native dynamic blocks, read attributes from `$attributes` (typed by WP from the
`registerBlockType` call). For post fields and meta, use the appropriate WP API. Never inline
the call inside HTML output.

```php
$title = $attributes['title'] ?? '';            // block attribute
$url   = get_post_meta( $post_id, 'url', true ); // post meta
```

### 3. Escape every output

| Output context       | Function               |
| -------------------- | ---------------------- |
| Plain text           | `esc_html( $var )`     |
| HTML attribute       | `esc_attr( $var )`     |
| URL (href, src)      | `esc_url( $var )`      |
| Rich text / WYSIWYG  | `wp_kses_post( $var )` |
| Inline style value   | `esc_attr( $var )`     |
| `<textarea>` content | `esc_textarea( $var )` |
| Inline JS            | `esc_js( $var )`       |

Never `echo $attributes['x']` or any other raw value directly.

### 4. Hardcoded paths

Replace with `home_url( '/path' )` wrapped in `esc_url()`:

```php
echo esc_url( home_url( '/contact' ) );
```

### 5. Theme-relative asset paths

Use `get_template_directory_uri()` wrapped in `esc_url()`:

```php
echo esc_url( get_template_directory_uri() . '/assets/images/logo.svg' );
```

### 6. WP function output

- `get_the_title()`, `get_the_excerpt()` → wrap in `esc_html()`.
- `get_the_post_thumbnail()` and `do_shortcode()` return trusted HTML — leave unwrapped.

### 7. PHPDoc for dynamic `block.php` templates

Native dynamic block render templates receive three variables injected by `register_block_type`.
Document them at the top so phpstan and readers understand the signatures:

```php
/**
 * @var array    $attributes Block attributes (typed by WP from the registerBlockType call).
 * @var string   $content    Inner block content (empty for blocks without InnerBlocks).
 * @var WP_Block $block      Block instance.
 */
```

### 8. User input

Sanitize before use:

```php
$key = sanitize_text_field( wp_unslash( $_GET['key'] ?? '' ) );
```

---

## Workflow checklist

1. Read each SCSS file and its paired PHP file together before editing.
2. Convert the SCSS to nested BEM. Identify styles shared with other components and extract to a mixin.
3. Update the PHP: ABSPATH guard, top-declared variables, escaped output, fixed URLs.
4. Run `php -l` on every PHP file touched.
5. After all components are done, run `npm run build` from `_dev/` and verify it succeeds.
6. Commit SCSS source files + compiled CSS output together (`dist/` in FSE projects).

### Reference file

Use the cleanest existing component as a reference for both SCSS and PHP structure — typically
the most recently refactored one.
