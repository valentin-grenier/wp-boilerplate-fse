# Architecture

How the repository is laid out and why. This is the reference for agents and humans who need to
understand where things live and what is safe to touch.

## Repository layout

```
.
├── .claude/                     # Claude Code config + team docs (Claude-only workflow)
│   ├── CLAUDE.md                # Session-start context (French)
│   ├── ARCHITECTURE.md          # This file
│   ├── BLOCKS.md                # Block authoring guide
│   ├── CONVENTIONS.md           # Prefixes, security, i18n, git
│   ├── IMPLEMENTATION.md        # Modernization tracker (temporary — can be archived post-ship)
│   ├── settings.json            # Permissions + hooks
│   └── rules/ · agents/ · commands/ · skills/ · lessons.md
├── .ddev/                       # DDEV config (versioned — reproducible local env)
├── .github/                     # Workflows, CODEOWNERS, Copilot instructions, templates, Dependabot
├── bin/                         # Shell scripts: setup.sh, cleanup.sh, smoke.sh, session-banner.sh, …
├── wp-content/themes/theme-fse/ # The theme — the only application code in this repo
│   ├── style.css                # WP header + base styles (text-domain, version, author, PHP req)
│   ├── theme.json               # FSE config: palette, typography, spacing, layout (WP schema)
│   ├── functions.php            # require-only: glob(inc/*.php), no business logic
│   ├── inc/                     # PHP modules split by concern — auto-loaded by functions.php
│   ├── templates/               # FSE templates (.html): index, home, single, page, archive, 404
│   ├── parts/                   # FSE template parts: header, footer
│   ├── styles/                  # FSE style variations (.json)
│   ├── patterns/                # Block patterns (.php with header docblock)
│   ├── languages/               # .pot / .po / .mo translation files
│   ├── assets/                  # (Legacy / miscellaneous non-compiled assets if any)
│   ├── _dev/                    # Source: SCSS, JS, blocks, webpack — edit here, not in dist/
│   └── dist/                    # Webpack output — committed so FTP deploy works
├── composer.json / composer.lock
├── CHANGELOG.md · README.md (French) · LICENSE
└── phpcs.xml.dist · phpstan.neon.dist · phpunit.xml.dist
```

WordPress core files (`wp-admin/`, `wp-includes/`, `wp-config*.php`, `wp-*.php` at root) exist locally
to run the site but are gitignored. They are never edited by hand.

## The theme: `wp-content/themes/theme-fse/`

The theme is a single flat FSE theme; there is no parent/child relationship. Its public surface is
defined by four top-level files:

- `style.css` — the WP Theme header block (Theme Name, Text Domain, Requires PHP, etc.).
- `theme.json` — global FSE settings + the Gutenberg features enabled by the theme.
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

Every file begins with `if ( ! defined( 'ABSPATH' ) ) { exit; }` to prevent direct HTTP access.
`phpcs` enforces this (`WordPress.Files.FileName` + repo rules).

### `_dev/` — the build pipeline

```
_dev/
├── blocks/{name}/       # One folder per custom block
│   ├── block.json       # WP block metadata (with $schema ref)
│   ├── block.php        # Server render template (ACF)
│   ├── block.js         # Editor-side script (can be empty)
│   └── block.scss       # Scoped styles
├── js/                  # theme.js (frontend) + editor.js (backend)
├── scss/                # theme.scss (frontend) + editor.scss + partials
├── scripts/make-block.js # Interactive block scaffolder (npm run make-block)
├── webpack.common.js
├── webpack.dev.js       # npm run dev — with BrowserSync
├── webpack.prod.js      # npm run build — minified + hashed
├── package.json
├── .eslintrc.json       # @wordpress/eslint-plugin
├── .stylelintrc.json    # @wordpress/stylelint-config
├── .prettierrc
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
**Never edit `dist/` directly.** The `.claude/settings.json` `permissions.deny` list blocks writes
there for agents, and CI fails if it detects a source/dist drift.

## Environments

| Env        | Purpose                          | Branch           | Deploy           |
|------------|----------------------------------|------------------|------------------|
| Local      | Dev on DDEV                      | `feature/*`      | —                |
| Staging    | Client preview / QA              | `staging`        | `.github/workflows/deploy-staging.yml` (FTP) |
| Production | Live                             | `main`           | `.github/workflows/deploy-production.yml` (FTP) |

Integration branch: `development`. Flow: `feature/* → development → staging → main`.

## CI/CD

- **`.github/workflows/ci.yml`** — PR lint+stan+build: matrix PHP 8.2 (composer lint, stan, test) +
  Node 20 (npm lint + build).
- **`.github/workflows/claude-review.yml`** — Anthropic Claude Code Action reviews PRs against
  `.claude/CLAUDE.md` + `.claude/CONVENTIONS.md`.
- **`.github/workflows/deploy-*.yml`** — FTP deploy on push to `staging` / `main`.
- **`dependabot.yml`** — weekly npm (`_dev/`) + GitHub Actions updates.
- **Branch protection on `main`** — seeded by `bin/setup-branch-protection.sh` (uses `gh` CLI).

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

# Before pushing
composer ci
bin/smoke.sh
```

## Design constraints to preserve

- **`functions.php` stays a one-liner.** Logic belongs in `inc/*.php`.
- **Webpack is the build, not `wp-scripts`** — do not propose a migration without explicit approval.
- **ACF Pro** is the block content layer (install via `auth.json`, see `auth.json.example`).
- **Text-domain is a single string everywhere.** `bin/setup.sh` replaces it on client install; the
  source default is `studioval-boilerplate`.
