# Security rules (WordPress theme)

These are blocking in code review. Any PR that violates them gets the changes flagged.

## Escape every output

- Text → `esc_html()`
- HTML attributes → `esc_attr()`
- URLs (href, src, action) → `esc_url()`
- Rich content (WYSIWYG, RichText) → `wp_kses_post()`
- `<textarea>` content → `esc_textarea()`
- Inline JS → `esc_js()`

**Never** `echo $attributes['x']` or `echo $var`. Wrap or pre-escape.

## Sanitize every input

- Free text → `sanitize_text_field()`
- Email → `sanitize_email()`
- Integer → `absint()`
- Slug → `sanitize_key()` or `sanitize_title()`
- Rich content → `wp_kses_post()` or `wp_kses()` with a custom allowlist

Sanitize on read, escape on write.

## Nonce every state-changing action

- Forms: `wp_nonce_field( 'action', 'field' )` on render, `check_admin_referer( 'action', 'field' )` on submit.
- AJAX: `wp_create_nonce( 'action' )` + `check_ajax_referer( 'action', 'nonce' )`.
- Links that trigger changes (`admin-post.php?...`): `wp_nonce_url()`.

## Prepare every SQL query

Use `$wpdb->prepare()` with placeholders (`%s`, `%d`, `%f`, `%i` for identifiers on WP 6.2+). Never interpolate `$_GET`, `$_POST`, or user-controlled variables directly into query strings.

## Defense in depth

- Every file in `wp-content/themes/theme-fse/inc/` opens with `if ( ! defined( 'ABSPATH' ) ) { exit; }`.
- Sensitive files are blocked by `.claude/settings.json` `permissions.deny`: `wp-config*.php`, `wp-admin/**`, `wp-includes/**`, `vendor/**`, `node_modules/**`, `dist/**`.

## Enforcement

- phpcs (WordPress-Extra) catches most of these statically. Run `composer lint` before committing.
- phpstan flags wrong arg counts and return types. Run `composer stan`.
- `composer ci` runs both plus phpunit in one pass.
