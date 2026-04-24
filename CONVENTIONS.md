# Conventions

Repository-wide conventions enforced by linters, reviewers, and Claude Code rules. Deviations need
explicit justification in the PR description.

## Naming

### Text-domain

**`studioval-boilerplate`** — the single source text-domain. Used in every `__()`, `esc_html__()`,
`_e()`, `_x()`, `_n()`, `_ex()`, `block.json` `textdomain`, and the `Text Domain:` header in
`style.css`. `bin/setup.sh` substitutes the `boilerplate` segment with the client slug on install.

No aliases. No `studio-val`, `studio-theme`, `theme-name`. phpcs (`WordPress.WP.I18n.TextDomainMismatch`)
enforces.

### PHP function / hook prefix

**`sv_boilerplate_`** — every function declared in `inc/*.php` and every custom `add_action` /
`add_filter` hook name must use this prefix. Examples:

```php
function sv_boilerplate_register_post_types() { … }
add_action( 'init', 'sv_boilerplate_register_post_types' );

do_action( 'sv_boilerplate_after_header' );
apply_filters( 'sv_boilerplate_social_links', $links );
```

WordPress-core hook names (`init`, `wp_head`, `enqueue_block_editor_assets`, …) are used as-is;
the prefix only applies to custom code.

### PHP namespace

**`StudioVal\Boilerplate\`** — PSR-4 under `wp-content/themes/theme-fse/inc/`. Declared in
`composer.json` `autoload.psr-4`.

```php
namespace StudioVal\Boilerplate\Blocks;

class HeroRenderer { … }
```

Only use classes where a namespace actually pays: block renderers, service objects, value objects.
Procedural hook callbacks stay procedural.

### Block namespace

**`studioval/{slug}`** — the slug in `block.json` `name`. Matches the block category `studioval`
registered in `inc/block-categories.php`.

## Security

All four of these are blocking in code review:

1. **Escape all output.** `esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`, `esc_textarea`, `esc_js`.
2. **Sanitize all input.** `sanitize_text_field`, `sanitize_email`, `absint`, `sanitize_key`,
   `wp_kses_post`. Sanitize on read, escape on write.
3. **Nonce every state-changing action.** `wp_nonce_field` → `check_admin_referer` /
   `wp_verify_nonce`. Including AJAX and admin-post handlers.
4. **Prepare every SQL query.** `$wpdb->prepare()` with placeholders — never interpolate user input
   into raw SQL.

Every `inc/*.php` file opens with:

```php
<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}
```

## i18n

Every user-visible string goes through a translation function with the text-domain as the second
argument:

```php
esc_html__( 'Read more', 'studioval-boilerplate' )
esc_attr__( 'Open menu', 'studioval-boilerplate' )
_x( 'Home', 'breadcrumb label', 'studioval-boilerplate' )
```

Regenerate the `.pot` after adding strings:

```bash
ddev wp i18n make-pot wp-content/themes/theme-fse \
	wp-content/themes/theme-fse/languages/studioval-boilerplate.pot
```

## CSS / SCSS

- **BEM** — `.block`, `.block__element`, `.block--modifier`.
- **No generic global selectors** inside block SCSS; scope everything to `.{block-slug}`.
- **Variables via `theme.json` CSS custom properties** where possible (`var(--wp--preset--color--primary)`).
- Fallback to SCSS variables in `_dev/scss/abstracts/` only for build-time values.
- Stylelint runs the `@wordpress/stylelint-config` ruleset.

## JavaScript

- ES2022, modules, no jQuery in new code (WP core still ships it; opt out of it per enqueue).
- ESLint runs `@wordpress/eslint-plugin/recommended`.
- Editor-side scripts live in `_dev/blocks/{slug}/block.js`; frontend scripts in `_dev/js/`.

## PHP

- **PHP 8.2+.** `style.css` advertises `Requires PHP: 8.2`; `composer.json` pins `config.platform.php`.
- Typed parameters and return types where they don't collide with WP core signatures.
- Short array syntax `[]` only. No `array()`.
- WordPress-Extra phpcs ruleset (see `phpcs.xml.dist`); level 5 phpstan with
  `szepeviktor/phpstan-wordpress` bootstrap (see `phpstan.neon.dist`).

## Files that must never be edited

Enforced by `.claude/settings.json` `permissions.deny`:

- `wp-admin/**`, `wp-includes/**`, `wp-config*.php`, `wp-*.php` at root — WP core.
- `vendor/**`, `**/node_modules/**`, `dist/**` — generated.
- `auth.json` — ACF Pro credentials.

## Git

- **Conventional Commits.** Type + optional scope + imperative subject.
  ```
  feat(blocks): add hero block with ACF fields
  fix(theme): escape alt text in gallery pattern
  chore(deps): bump @wordpress/eslint-plugin
  docs: update BLOCKS.md scaffolding section
  ```
- Allowed types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, `style`.
- **Branch flow:** `feature/<ticket>-<slug>` → `development` → `staging` → `main`. Never push
  directly to `main` or `staging`. Branch protection (see `bin/setup-branch-protection.sh`) blocks
  force-pushes and deletions on `main`.
- **One commit per modernization batch** when working through a multi-step migration.

## PR checklist

See `.github/PULL_REQUEST_TEMPLATE.md`. CI (`ci.yml`) + Claude Code Action (`claude-review.yml`) must
be green before merge. Apply suggested fixes as separate commits; never amend a published commit.
