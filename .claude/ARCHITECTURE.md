# Architecture

How the repository is laid out and why. For the day-to-day commands see
[`../docs/setup.md`](../docs/setup.md); for block authoring see
[`../docs/blocks.md`](../docs/blocks.md).

## Repository layout

```text
.
├── .claude/                     # Claude Code config + team docs
│   ├── CLAUDE.md                # Session-start context (auto-loaded)
│   ├── ARCHITECTURE.md          # This file
│   ├── CONVENTIONS.md           # Git workflow + tooling reference
│   ├── rules/                   # Auto-loaded rules: security, i18n, a11y, blocks, components
│   ├── settings.json            # Permissions allow/deny + hooks
│   ├── hooks/                   # Hook scripts (session-banner, lint-edited, append-lesson)
│   ├── agents/                  # Review sub-agent(s)
│   ├── commands/                # Slash commands
│   ├── skills/                  # On-demand slash-command skills (audits + scaffolders)
│   └── lessons.md               # Rolling log appended by the PreCompact hook
├── .ddev/                       # DDEV config (versioned — reproducible local env)
├── .github/                     # Workflows, CODEOWNERS, Copilot instructions, templates, Dependabot
│   └── workflows/               # ci.yml, pr-checklist.yml, deploy-staging.yml, deploy-production.yml
├── bin/
│   ├── setup.sh                 # Client-project bootstrap (placeholder substitution + WP install)
│   ├── setup-branch-protection.sh # Idempotent gh helper: CI gate + CODEOWNER review on main
│   ├── reset-theme-json.sh      # Reset theme.json to the boilerplate default
│   └── smoke.sh                 # End-to-end smoke check (DB, theme, lint, stan, build)
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
├── wp-content/plugins/studioval-plugin-boilerplate/ # Companion plugin scaffold (OOP, Singleton)
├── composer.json                # PHP deps + scripts
├── phpcs.xml.dist               # phpcs ruleset (WordPress-Extra + PHPCompatibility WP 8.2)
├── phpstan.neon.dist            # phpstan config (level 5 + szepeviktor/phpstan-wordpress)
├── phpunit.xml.dist             # phpunit config (tests/ testsuite — empty for now)
├── .mcp.json                    # Claude Code MCP config — WordPress via DDEV WP-CLI (STDIO)
├── CHANGELOG.md                 # Keep-a-Changelog
├── README.md                    # User-facing project overview
├── .editorconfig
├── .nvmrc                       # Node 20
└── .env.example
```

WordPress core files (`wp-admin/`, `wp-includes/`, `wp-config*.php`, `wp-*.php` at root) exist locally
to run the site but are gitignored. They are never edited by hand.

## The theme: `wp-content/themes/theme-fse/`

The theme is a single flat FSE theme; there is no parent/child relationship. Its public surface is
defined by its top-level files:

- `style.css` — the WP Theme header block (Theme Name, Text Domain, Requires PHP, etc.). Source
  text-domain: `studioval-boilerplate` (substituted by `bin/setup.sh` on client install). `Requires PHP`: `8.2`.
- `theme.json` — global FSE settings. Has `$schema: https://schemas.wp.org/trunk/theme.json`.
- `functions.php` — intentionally trivial: `foreach ( glob( …/inc/*.php ) as $f ) require_once $f;`.
- `index.php` — WP fallback; not used in FSE rendering.

### `inc/` — modular PHP

Every file is auto-loaded by `functions.php`. Each one owns one concern:

| File                    | Responsibility                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------- |
| `theme-setup.php`       | `add_theme_support` calls, menus, image sizes, editor styles                          |
| `theme-assets.php`      | `wp_enqueue_scripts` / `enqueue_block_editor_assets` with `filemtime()` cache-busting |
| `blocks.php`            | Enqueues compiled block bundles from `dist/blocks/*/` (editor + front-end)            |
| `block-bindings.php`    | Custom block bindings source registration                                             |
| `block-categories.php`  | `block_categories_all` filter: adds the theme's custom category                       |
| `block-settings.php`    | Per-block allow/deny lists (disable unused core blocks/styles)                        |
| `security.php`          | Hardening: XML-RPC off, file editor off, version info hidden                          |
| `performance-hooks.php` | Strip bloat: emoji scripts, oEmbed, unused head links                                 |
| `post-types.php`        | Custom post types registration (if/when any)                                          |
| `media-uploads.php`     | MIME type allowances, SVG handling, image quality                                     |
| `user-capabilities.php` | Role tuning (subscriber/editor caps)                                                  |
| `dashboard.php`         | Admin dashboard cleanup (remove default widgets, add custom)                          |
| `comments.php`          | Comments UI / template overrides                                                      |
| `hooks.php`             | Catch-all for small hooks that don't warrant their own file                           |

**Convention:** every file begins with `if ( ! defined( 'ABSPATH' ) ) { exit; }` to prevent direct
HTTP access.

### `_dev/` — the build pipeline

```text
_dev/
├── blocks/{name}/       # One folder per custom block — see block-example-static and block-example-dynamic
├── js/                  # theme.js (frontend) + editor.js (backend)
├── scss/                # theme.scss (frontend) + editor.scss + partials
├── scripts/make-block.js # Interactive block scaffolder (npm run make-block)
├── webpack.common.js    # + webpack.dev.js (npm run dev, BrowserSync) + webpack.prod.js (npm run build)
├── package.json         # devDeps + scripts (dev, build, make-block, lint, format)
├── .eslintrc.json       # @wordpress/eslint-plugin — lint:js
├── .stylelintrc.json    # @wordpress/stylelint-config/scss — lint:css
└── .prettierrc          # Shared formatter config (tabs, print-width 100)
```

Compiled output goes to `../dist/` (committed). Deploy workflows FTP-upload that directory as-is.

### Block discovery

Blocks register themselves **client-side** via `registerBlockType('studioval/{slug}', …)` in
`_dev/blocks/{slug}/{slug}.js` — no `block.json`, no manual registration list. `inc/blocks.php` globs
`dist/blocks/*/` and enqueues whichever bundles exist on the right action. Full guide:
[`../docs/blocks.md`](../docs/blocks.md); review checklist: [`rules/blocks.md`](rules/blocks.md).

### `dist/` — compiled output

Committed because the deploy workflows are FTP-based and do not run a build step on the remote.
**Never edit `dist/` directly** — `settings.json` `permissions.deny` blocks writes there for agents.

## Claude Code config (`.claude/`)

`CLAUDE.md` is the only file auto-loaded every session; the `rules/` files are loaded alongside it as
passive checklists applied when writing or reviewing code. `agents/`, `commands/` and `skills/` are
invoked on demand. Rather than mirror their contents here (which drifts), inspect the live state with
`ls .claude/{rules,agents,commands,skills}`. The `docs-sync` skill audits these team docs against that
live state when Claude-logic files change.

## Environments

**This template repo** has no live environment: `main` is the pristine base (default branch), `demo` is an installed example, and both deploy workflows are guarded off (`if: github.repository != …`).

**Generated client projects** use these environments:

| Env        | Purpose             | Branch      | Deploy                                          |
| ---------- | ------------------- | ----------- | ----------------------------------------------- |
| Local      | Dev on DDEV         | `feature/*` | —                                               |
| Staging    | Client preview / QA | `staging`   | `.github/workflows/deploy-staging.yml` (FTP)    |
| Production | Live                | `main`      | `.github/workflows/deploy-production.yml` (FTP) |

Integration branch: `development`. Flow: `feature/* → development → staging → main`.

## CI/CD

- `ci.yml` — PHP (lint + stan + test) + Node (lint + build) on every PR and push to `main` / `staging` / `development`.
- `pr-checklist.yml` — fails the PR check while any item in the `## Checklist` section is unchecked.
- `deploy-*.yml` — FTP deploy on push to `staging` / `main` **in client projects**; guarded off on this template repo (`if: github.repository != …`). `setup.sh` strips the guard for generated projects.
- `dependabot.yml` — weekly npm (`_dev/`) + GitHub Actions updates.
- `CODEOWNERS` — single owner: `@valentin-grenier`.
- `bin/setup-branch-protection.sh` — idempotent `gh` helper that enforces the CI gate and CODEOWNER review on `main`.

## Design constraints to preserve

- **`functions.php` stays a one-liner.** Logic belongs in `inc/*.php`.
- **Webpack is the build, not `wp-scripts`** — do not propose a migration without explicit approval.
- **Native Gutenberg blocks only.** Blocks register themselves client-side via `registerBlockType` (no `block.json`); compiled bundles are enqueued from `dist/blocks/*/` by `inc/blocks.php`. No ACF dependency.
- **Single text-domain.** Source default is `studioval-boilerplate` (per `style.css` header); `bin/setup.sh` substitutes it on client install.
