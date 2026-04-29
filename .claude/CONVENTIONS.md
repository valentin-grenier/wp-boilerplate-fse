# Conventions

Repository-wide conventions.

## Naming

### Text-domain

**`studioval-boilerplate`** — declared in [`style.css`](../wp-content/themes/theme-fse/style.css)
header (`Text Domain: studioval-boilerplate`, `Domain Path: /languages`). Every `__()` /
`esc_html__()` / `_x()` and every i18n string in block JS metadata in the theme use this exact value.
`bin/setup.sh` substitutes the `boilerplate` token with the client project slug on install.
Enforced by phpcs via the `WordPress.WP.I18n.TextDomainMismatch` sniff in `phpcs.xml.dist`.

### PHP function / hook prefix

**`sv_boilerplate_`** — every function declared in `inc/*.php` and every custom `add_action` /
`add_filter` hook name uses this prefix. Examples in the codebase:

```php
function sv_boilerplate_register_post_types() { … }
add_action( 'init', 'sv_boilerplate_register_post_types' );
```

WordPress-core hook names (`init`, `wp_head`, `enqueue_block_editor_assets`, …) are used as-is;
the prefix only applies to custom code. `bin/setup.sh` substitutes the `boilerplate` token with
the client project slug on install.

### PHP namespace

**`StudioVal\Boilerplate\`** — declared in [`composer.json`](../composer.json) `autoload.psr-4`,
maps to `wp-content/themes/theme-fse/inc/`. Currently no PSR-4 classes exist; the namespace is
reserved for when class-based code is introduced. `bin/setup.sh` substitutes the `Boilerplate`
segment with the client name on install.

### Block namespace

**`studioval/{slug}`** — the first argument to `registerBlockType` in each block's editor JS. Already applied to the example blocks in `_dev/blocks/block-example-static/` and `_dev/blocks/block-example-dynamic/`.

A custom block category `studioval` is registered by
[`inc/block-categories.php`](../wp-content/themes/theme-fse/inc/block-categories.php). New blocks
should target it instead of WP core categories like `layout`.

## Security

The four blocking standards in code review:

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
	exit; // Exit if accessed directly.
}
```

Applied uniformly across all 14 files. Enforced implicitly by code review (phpcs doesn't have a
sniff for this specific pattern, but the convention is consistent).

## i18n

Every user-visible string goes through a translation function with the text-domain as the second
argument:

```php
esc_html__( 'Read more', 'studioval-boilerplate' )
esc_attr__( 'Open menu', 'studioval-boilerplate' )
_x( 'Home', 'breadcrumb label', 'studioval-boilerplate' )
```

⚠️ **Current state:** text-domains normalized to `studioval-boilerplate` across all files.

A `languages/studioval-boilerplate.pot` stub is committed. Regenerate it before every release via:

```bash
ddev wp i18n make-pot wp-content/themes/theme-fse \
    wp-content/themes/theme-fse/languages/studioval-boilerplate.pot
```

## CSS / SCSS

- **BEM** — `.block`, `.block__element`, `.block--modifier`.
- **No generic global selectors** inside block SCSS; scope everything to `.{block-slug}`.
- **Variables via `theme.json` CSS custom properties** where possible
  (`var(--wp--preset--color--primary)`).
- Fallback to SCSS variables in `_dev/scss/abstracts/` only for build-time values.
- **Stylelint** — `@wordpress/stylelint-config/scss` via
  [`_dev/.stylelintrc.json`](../wp-content/themes/theme-fse/_dev/.stylelintrc.json); run from
  `_dev/` with `npm run lint:css` (auto-fix: `npm run lint:css:fix`). Scans `scss/**/*.scss` and
  `blocks/**/*.scss`.

## JavaScript

- ES2022, modules, no jQuery in new code (WP core still ships it; opt out of it per enqueue).
- Editor-side scripts live in `_dev/blocks/{slug}/block.js`; frontend scripts in `_dev/js/`.
- **ESLint** — `@wordpress/eslint-plugin/recommended` via
  [`_dev/.eslintrc.json`](../wp-content/themes/theme-fse/_dev/.eslintrc.json); run from `_dev/`
  with `npm run lint:js` (auto-fix: `npm run lint:js:fix`). Scans `js/`, `blocks/`, `scripts/`.

## Formatting

- `npm run format` (from `_dev/`) — Prettier; applies to `**/*.{js,json,md,scss}`.
- `npm run lint:css` — Stylelint; scans `scss/**/*.scss` and `blocks/**/*.scss`.
- `npm run lint:js` — ESLint; scans `js/`, `blocks/`, `scripts/`.
- `npm run lint` — runs `lint:js` + `lint:css` together.

## PHP

- **PHP 8.2+** — `composer.json` requires `>=8.2` and pins `config.platform.php`; `style.css`
  declares `Requires PHP: 8.2`.
- Short array syntax `[]` only. No `array()`.

### Tooling — what each tool does

Config files live at the repo root as `<tool>.<ext>.dist` (the non-`.dist` versions are gitignored so local overrides never leak).

| Tool      | Purpose                                                        | Config file                                 | Run with                                                               |
| --------- | -------------------------------------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------- |
| `phpcs`   | Style + known-unsafe-pattern linter (WordPress-Extra ruleset). | [`phpcs.xml.dist`](../phpcs.xml.dist)       | `composer lint` (report) / `composer lint:fix` (auto-fix via `phpcbf`) |
| `phpstan` | Static analyzer — finds logic bugs without running the code.   | [`phpstan.neon.dist`](../phpstan.neon.dist) | `composer stan`                                                        |
| `phpunit` | Test runner. Picks up `tests/**Test.php`.                      | [`phpunit.xml.dist`](../phpunit.xml.dist)   | `composer test`                                                        |

**What "phpcs" catches:** indentation, docblocks, unescaped `echo`, missing nonces, text-domain
mismatches, direct SQL without `$wpdb->prepare`, `array()` instead of `[]`, etc. WordPress-Extra is
the broader of WP's two official rulesets — stricter than plain WordPress, looser than VIP.

**What "phpstan" catches:** calls to undefined functions, wrong argument types, paths that should
return a value but don't, unreachable code. Level 5 is the sweet spot for WP code. The
`szepeviktor/phpstan-wordpress` extension teaches phpstan the WP API (`add_action`,
`wp_kses_post`, `$wpdb`, `register_block_type`…) — without it, every WP call would be flagged as
"unknown function".

**What "phpunit" does:** runs test classes that extend `PHPUnit\Framework\TestCase`. No tests
exist yet; the config is pre-wired so `composer test` exits 0 today and picks up new files
dropped in `tests/` later.

**`composer ci`** runs all three (`lint` → `stan` → `test`) as one gate for CI and local pre-push.

## Files that must never be edited

Enforced by [`settings.json`](settings.json) `permissions.deny`:

- `wp-admin/**`, `wp-includes/**`, `wp-config*.php` — WP core.
- `vendor/**`, `**/node_modules/**`, `dist/**` — generated.

## Git

**Semantic Commits.**

**Pattern:**

```text
<type>: <Scope> - <Subject>
```

- **`<type>`** — lowercase, required. One of the types listed below.
- **`<Scope>`** — capitalized, optional. The block, template, component, or area affected
  (e.g., `Single`, `Header`, `FAQ`, `README`, `Template`). Omit when the change is global.
- **`<Subject>`** — capitalized, required. Past tense (preterit) verb + brief description.

Examples:

- `feat: Single - Added breadcrumb block`
- `fix: Single - Resolved PHP notice in header block`
- `docs: README - Updated setup instructions`
- `style: FAQ - Edited toggle icon size`
- `refactor: Template - Renamed block template file for clarity`

Allowed types:

- `feat` — new feature for the user (not a new feature for a build script).
- `fix` — bug fix for the user (not a fix to a build script).
- `docs` — changes to documentation.
- `style` — formatting, missing semicolons, etc.; no production code change.
- `refactor` — refactoring production code (e.g., renaming a variable).
- `perf` — performance improvement; no functional change.
- `test` — adding missing tests or refactoring tests; no production code change.
- `build` — changes to the build system or external dependencies (Webpack, Composer, npm).
- `ci` — changes to CI configuration (`.github/workflows/**`, `dependabot.yml`).
- `chore` — updating tooling, dev tasks, or anything else that doesn't fit above; no production code change.

**Branch flow:** `feature/<ticket>-<slug>` → `development` → `staging` → `main`. Never push directly
to `main` or `staging`.

⚠️ **Branch protection on `main` is not automatically active.** Run `bin/setup-branch-protection.sh` once locally (requires `gh auth login`) to enforce the CI gate and CODEOWNER review.

## PR checklist

See [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md). The current template
covers PR type, conventions, asset compilation, escaping, security guards, and docs.

✅ **CI runs on every PR.** `ci.yml` gates PHP lint/stan/test + Node lint/build.
