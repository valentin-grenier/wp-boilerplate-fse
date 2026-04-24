# Conventions

Repository-wide conventions. This document describes the **current** state at HEAD. The
post-modernization target (WordPress-Extra phpcs, phpstan level 5, PHP 8.2 floor, normalized
text-domain, new prefix scheme) lives in [`IMPLEMENTATION.md`](IMPLEMENTATION.md).

## Naming

### Text-domain

**`fse-boilerplate`** — declared in [`style.css`](../wp-content/themes/theme-fse/style.css) header
(`Text Domain: fse-boilerplate`). `bin/setup.sh` substitutes it for the client slug on install.

⚠️ **Current state:** the codebase is inconsistent. The `style.css` header says `fse-boilerplate`,
but `inc/*.php` files use a mix of `studio-val`, `studio-theme`, `theme-name`, and `fse-boilerplate`
in `__()` calls. Normalization is tracked in `IMPLEMENTATION.md` Batch 4. **For new code, use
`fse-boilerplate`.**

### PHP function / hook prefix

**`studio_`** — every function declared in `inc/*.php` and every custom `add_action` / `add_filter`
hook name uses this prefix. Examples in the codebase:

```php
function studio_register_post_types() { … }
add_action( 'init', 'studio_register_post_types' );
```

WordPress-core hook names (`init`, `wp_head`, `enqueue_block_editor_assets`, …) are used as-is;
the prefix only applies to custom code. `bin/setup.sh` substitutes `studio_` → client-specific
prefix on install.

### PHP namespace

**`StudioVal\WPBoilerplate\`** — declared in [`composer.json`](../composer.json) `autoload.psr-4`,
maps to `wp-content/themes/theme-fse/inc/`. Currently no PSR-4 classes exist; the namespace is
reserved for when class-based code is introduced.

### Block namespace

**`studioval/{slug}`** — the slug in `block.json` `name`. Already applied (the only block in the
repo is `studioval/block`, the scaffolder template).

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

Every `inc/*.php` file should open with:

```php
<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}
```

⚠️ **Current state:** only `block-categories.php` and `hooks.php` (2 of 14) have the guard. The
other 12 are tracked for fixing in `IMPLEMENTATION.md` Batch 4.

## i18n

Every user-visible string goes through a translation function with the text-domain as the second
argument:

```php
esc_html__( 'Read more', 'fse-boilerplate' )
esc_attr__( 'Open menu', 'fse-boilerplate' )
_x( 'Home', 'breadcrumb label', 'fse-boilerplate' )
```

⚠️ **Current state:** mixed text-domains across files (see Naming → Text-domain above).

There is no `languages/` folder or `.pot` file yet (planned in `IMPLEMENTATION.md` Batch 6). Once
created, regenerate via:

```bash
ddev wp i18n make-pot wp-content/themes/theme-fse \
    wp-content/themes/theme-fse/languages/fse-boilerplate.pot
```

## CSS / SCSS

- **BEM** — `.block`, `.block__element`, `.block--modifier`.
- **No generic global selectors** inside block SCSS; scope everything to `.{block-slug}`.
- **Variables via `theme.json` CSS custom properties** where possible
  (`var(--wp--preset--color--primary)`).
- Fallback to SCSS variables in `_dev/scss/abstracts/` only for build-time values.

⚠️ **No Stylelint configured yet** (planned in `IMPLEMENTATION.md` Batch 3 — will use
`@wordpress/stylelint-config`).

## JavaScript

- ES2022, modules, no jQuery in new code (WP core still ships it; opt out of it per enqueue).
- Editor-side scripts live in `_dev/blocks/{slug}/block.js`; frontend scripts in `_dev/js/`.

⚠️ **No ESLint configured yet** (planned in `IMPLEMENTATION.md` Batch 3 — will use
`@wordpress/eslint-plugin`).

## PHP

- **PHP 8.2+** — `composer.json` requires `>=8.2` and pins `config.platform.php`; `style.css`
  declares `Requires PHP: 8.2`.
- Short array syntax `[]` only. No `array()`.
- **phpcs** — `WordPress-Extra` via [`phpcs.xml.dist`](../phpcs.xml.dist); run with `composer lint`
  (auto-fix with `composer lint:fix`). Text-domain sniff configured; `PHPCompatibility-WP` wired
  in the same ruleset targeting PHP 8.2.
- **phpstan** — level 5 via [`phpstan.neon.dist`](../phpstan.neon.dist) with the
  `szepeviktor/phpstan-wordpress` extension (bringing in WP core stubs). Run with `composer stan`.
- **phpunit** — configured via [`phpunit.xml.dist`](../phpunit.xml.dist) pointing to `tests/`;
  no test cases authored yet, so `composer test` is a no-op that exits 0.
- **`composer ci`** runs `lint` + `stan` + `test` in one go.

⚠️ **Lint/stan red at HEAD.** Tooling is in place (Batch 2) but the codebase still violates the
rules in known ways: 12 missing `ABSPATH` guards, 4 mixed text-domains, pre-migration prefixes.
Batch 4 fixes the guards + normalizes text-domains; Batch 5 migrates prefixes/namespaces.
`composer ci` becomes green after Batch 5.

## Files that must never be edited

Enforced by [`settings.json`](settings.json) `permissions.deny`:

- `wp-admin/**`, `wp-includes/**`, `wp-config*.php` — WP core.
- `vendor/**`, `**/node_modules/**`, `dist/**` — generated.
- `auth.json` — ACF Pro credentials.

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

**One commit per modernization batch** when working through `IMPLEMENTATION.md`.

⚠️ **Branch protection on `main` is not enforced** (no rule configured on the GitHub side, no
`bin/setup-branch-protection.sh` helper yet — planned in `IMPLEMENTATION.md` Batch 9).

## PR checklist

See [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md). The current template
covers PR type, conventions, asset compilation, escaping, security guards, and docs.

⚠️ **No CI lint/test runs on PRs yet.** Only the FTP deploy workflows exist; `ci.yml` and
`claude-review.yml` are planned in `IMPLEMENTATION.md` Batch 9.
