# Architecture

How the repository is laid out and why. This document describes the **current** state of the repo at
HEAD. The post-modernization target lives in [`IMPLEMENTATION.md`](IMPLEMENTATION.md).

## Repository layout

```text
.
├── .claude/                     # Claude Code config + team docs (Claude-only workflow)
│   ├── CLAUDE.md                # Session-start context
│   ├── ARCHITECTURE.md          # This file
│   ├── BLOCKS.md                # ACF block authoring guide
│   ├── CONVENTIONS.md           # Prefixes, security, i18n, git
│   ├── IMPLEMENTATION.md        # Modernization tracker (temporary)
│   └── settings.json            # Permissions allow/deny (no hooks yet)
├── .ddev/                       # DDEV config (versioned — reproducible local env)
├── .github/                     # Workflows, CODEOWNERS, Copilot instructions, templates, Dependabot
│   ├── workflows/
│   │   ├── deploy-staging.yml   # FTP deploy on push to staging
│   │   └── deploy-production.yml # FTP deploy on push to main
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CODEOWNERS
│   ├── copilot-instructions.md
│   └── dependabot.yml
├── bin/
│   ├── setup.sh                 # Client-project bootstrap (placeholder substitution + WP install)
│   └── cleanup.sh               # Post-setup cleanup
├── wp-content/themes/theme-fse/ # The theme — the only application code in this repo
│   ├── style.css                # WP header + base styles (text-domain, version, author, PHP req)
│   ├── theme.json               # FSE config: palette, typography, spacing, layout (with $schema)
│   ├── functions.php            # require-only: glob(inc/*.php), no business logic
│   ├── inc/                     # PHP modules split by concern — auto-loaded by functions.php
│   ├── templates/               # FSE templates (.html): index, home, single, page, archive, 404
│   ├── parts/                   # FSE template parts: header, footer
│   ├── styles/                  # FSE style variations (.json)
│   ├── _dev/                    # Source: SCSS, JS, blocks, webpack — edit here, not in dist/
│   └── dist/                    # Webpack output — committed so FTP deploy works
├── composer.json                # PHP deps + scripts (lockfile gitignored — known limitation)
├── phpcs.xml.dist               # phpcs ruleset (WordPress-Extra + PHPCompatibility WP 8.2)
├── phpstan.neon.dist            # phpstan config (level 5 + szepeviktor/phpstan-wordpress)
├── phpunit.xml.dist             # phpunit config (tests/ testsuite — empty for now)
├── tests/                       # placeholder; phpunit runs green with no tests today
├── auth.json.example            # Template for ACF Pro credentials
├── CHANGELOG.md                 # Keep-a-Changelog
├── README.md                    # User-facing project overview
├── LICENSE
├── .editorconfig
├── .nvmrc                       # Node 20
├── .env.example
└── .gitignore
```

WordPress core files (`wp-admin/`, `wp-includes/`, `wp-config*.php`, `wp-*.php` at root) exist locally
to run the site but are gitignored. They are never edited by hand.

## The theme: `wp-content/themes/theme-fse/`

The theme is a single flat FSE theme; there is no parent/child relationship. Its public surface is
defined by four top-level files:

- `style.css` — the WP Theme header block (Theme Name, Text Domain, Requires PHP, etc.). Current
  text-domain header value: `fse-boilerplate`. Current `Requires PHP`: `8.2`.
- `theme.json` — global FSE settings. Has `$schema: https://schemas.wp.org/trunk/theme.json`.
- `functions.php` — intentionally trivial: `foreach ( glob( …/inc/*.php ) as $f ) require_once $f;`.
- `index.php` — WP fallback; not used in FSE rendering.

### `inc/` — modular PHP

Every file is auto-loaded by `functions.php`. Each one owns one concern:

| File                      | Responsibility                                                            |
|---------------------------|---------------------------------------------------------------------------|
| `theme-setup.php`         | `add_theme_support` calls, menus, image sizes, editor styles              |
| `theme-assets.php`        | `wp_enqueue_scripts` / `enqueue_block_editor_assets` with `filemtime()` cache-busting |
| `block-acf.php`           | Auto-registers ACF blocks by globbing `_dev/blocks/*/block.json`          |
| `block-bindings.php`      | Custom block bindings source registration                                 |
| `block-categories.php`    | `block_categories_all` filter: adds the theme's custom category           |
| `block-settings.php`      | Per-block allow/deny lists (disable unused core blocks/styles)            |
| `security.php`            | Hardening: XML-RPC off, file editor off, version info hidden              |
| `performance-hooks.php`   | Strip bloat: emoji scripts, oEmbed, unused head links                     |
| `post-types.php`          | Custom post types registration (if/when any)                              |
| `media-uploads.php`       | MIME type allowances, SVG handling, image quality                         |
| `user-capabilities.php`   | Role tuning (subscriber/editor caps)                                      |
| `dashboard.php`           | Admin dashboard cleanup (remove default widgets, add custom)              |
| `comments.php`            | Comments UI / template overrides                                          |
| `hooks.php`               | Catch-all for small hooks that don't warrant their own file               |

**Convention:** every file begins with `if ( ! defined( 'ABSPATH' ) ) { exit; }` to prevent direct
HTTP access. Applied across all 14 files.

### `_dev/` — the build pipeline

```text
_dev/
├── blocks/{name}/       # One folder per custom block — currently only the template `block/`
│   ├── block.json       # WP block metadata
│   ├── block.php        # Server render template (ACF)
│   ├── block.js         # Editor-side script (intentionally empty in the template)
│   └── block.scss       # Scoped styles
├── js/                  # theme.js (frontend) + editor.js (backend)
├── scss/                # theme.scss (frontend) + editor.scss + partials
├── scripts/make-block.js # Interactive block scaffolder (npm run make-block)
├── webpack.common.js
├── webpack.dev.js       # npm run dev — with BrowserSync
├── webpack.prod.js      # npm run build — minified
├── package.json         # devDeps + scripts (dev, build, make-block, lint, format)
├── .eslintrc.json       # @wordpress/eslint-plugin — lint:js
├── .stylelintrc.json    # @wordpress/stylelint-config/scss — lint:css
├── .prettierrc          # Shared formatter config (tabs, print-width 100)
└── .prettierignore
```

Compiled output goes to `../dist/` (committed). Deploy workflows FTP-upload that directory as-is.

### Block discovery

The flow `_dev/blocks/*/block.json` → `inc/block-acf.php` is the contract. `block-acf.php` globs the
`_dev/blocks` tree and calls `register_block_type` on each `block.json` found. There is no manual
registration list; drop a folder into `_dev/blocks/`, run `npm run build`, and the block appears in
the editor.

Use `npm run make-block` to scaffold a new block folder (prompts for slug, title, icon, category).

### `dist/` — compiled output

Committed because the deploy workflows are FTP-based and do not run a build step on the remote.
**Never edit `dist/` directly.** The [`.claude/settings.json`](settings.json) `permissions.deny` list
blocks writes there for agents.

## Environments

| Env        | Purpose                          | Branch     | Deploy                                       |
|------------|----------------------------------|------------|----------------------------------------------|
| Local      | Dev on DDEV                      | `feature/*`| —                                            |
| Staging    | Client preview / QA              | `staging`  | `.github/workflows/deploy-staging.yml` (FTP) |
| Production | Live                             | `main`     | `.github/workflows/deploy-production.yml` (FTP) |

Integration branch: `development`. Flow: `feature/* → development → staging → main`.

## CI/CD (current)

- `.github/workflows/deploy-*.yml` — FTP deploy on push to `staging` / `main`.
- `.github/dependabot.yml` — weekly npm (`_dev/`) + GitHub Actions updates.
- `.github/CODEOWNERS` — single owner: `@valentin-grenier`.

⚠️ **No PR lint/test CI yet.** Planned in `IMPLEMENTATION.md` Batch 9 (`ci.yml` + `claude-review.yml`
+ branch protection helper).

## Developer workflow

```bash
# One-time setup on a client project
./bin/setup.sh --theme-dest=<client-slug>

# Day-to-day
ddev start
cd wp-content/themes/theme-fse/_dev
npm install && npm run dev            # watch + BrowserSync at https://wp-boilerplate-fse.ddev.site
# In another shell:
composer install
composer lint                          # phpcs (reads phpcs.xml.dist — WordPress-Extra)
composer stan                          # phpstan analyse (level 5, WP bootstrap)
composer ci                            # lint + stan + test
```

`composer ci` is green at HEAD (0 errors across phpcs + phpstan + phpunit). 18 phpcs warnings
remain and are non-blocking.

## Design constraints to preserve

- **`functions.php` stays a one-liner.** Logic belongs in `inc/*.php`.
- **Webpack is the build, not `wp-scripts`** — do not propose a migration without explicit approval.
- **ACF Pro** is the block content layer (install via `auth.json`, see `auth.json.example`).
- **Single text-domain.** Source default is `fse-boilerplate` (per `style.css` header); `bin/setup.sh`
  substitutes it on client install.
