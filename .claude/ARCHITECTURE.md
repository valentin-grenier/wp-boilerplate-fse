# Architecture

How the repository is laid out and why.

## Repository layout

```text
.
├── .claude/                     # Claude Code config + team docs (Claude-only workflow)
│   ├── CLAUDE.md                # Session-start context
│   ├── ARCHITECTURE.md          # This file
│   ├── BLOCKS.md                # Custom block authoring guide
│   ├── CONVENTIONS.md           # Prefixes, security, i18n, git
│   ├── settings.json            # Permissions allow/deny + 4 hooks
│   ├── hooks/                   # Hook scripts (session-banner, lint-edited, append-lesson)
│   ├── rules/                   # Auto-context rules: a11y.md, security.md, i18n.md, blocks.md
│   ├── agents/                  # wp-reviewer.md — review subagent
│   ├── commands/                # /smoke — slash command
│   ├── skills/                  # Slash-command skills (flat {name}.md files)
│   │   ├── sync-docs.md         # Auto-trigger: audits team-docs drift
│   │   ├── a11y-links-buttons.md # On-demand: WCAG/RGAA failure grep audit
│   │   ├── i18n-audit.md        # On-demand: text-domain and untranslated strings audit
│   │   └── block-audit.md       # On-demand: registerBlockType call structure audit
│   └── lessons.md               # Rolling log appended by the PreCompact hook
├── .ddev/                       # DDEV config (versioned — reproducible local env)
├── .github/                     # Workflows, CODEOWNERS, Copilot instructions, templates, Dependabot
│   ├── workflows/
│   │   ├── ci.yml               # PR + push gate: PHP lint/stan/test + Node lint/build
│   │   ├── pr-checklist.yml     # Fails the PR if any "## Checklist" box is unchecked
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
├── .mcp.json                    # MCP server template (Notion commented out)
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
HTTP access. Applied across all 14 files.

### `_dev/` — the build pipeline

```text
_dev/
├── blocks/{name}/       # One folder per custom block — see block-example-static and block-example-dynamic
│   ├── {name}.js              # Editor: registerBlockType + edit + save (all metadata client-side)
│   ├── {name}.scss            # Shared styles (editor + front-end)
│   ├── {name}-editor.scss     # Editor-only styles
│   ├── {name}-frontend.js     # Front-end script
│   └── {name}.php             # Optional — only for dynamic blocks (referenced by `render` in the JS)
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

Blocks register themselves **client-side** via `registerBlockType('studioval/{slug}', { …metadata, edit, save })` in `_dev/blocks/{slug}/{slug}.js`. Webpack compiles each block to `dist/blocks/{slug}/` with normalised filenames (`block.js`, `block.css`, `block-editor.css`, `block-frontend.js`). [`inc/blocks.php`](../wp-content/themes/theme-fse/inc/blocks.php) globs `dist/blocks/*/` and enqueues whichever bundles exist on the right action — editor-only on `enqueue_block_editor_assets`, shared styles + front-end JS on `wp_enqueue_scripts`. No `block.json`, no manual registration list.

Use `npm run make-block {slug}` to scaffold a new block folder (prompts for static or dynamic).

### `dist/` — compiled output

Committed because the deploy workflows are FTP-based and do not run a build step on the remote.
**Never edit `dist/` directly.** The [`.claude/settings.json`](settings.json) `permissions.deny` list
blocks writes there for agents.

## Claude Code config (`.claude/`)

### Rules

Files under `.claude/rules/` are auto-loaded as context on every session. Each file covers one concern and acts as a passive checklist Claude applies when writing or reviewing code.

| File          | Scope                                                     |
| ------------- | --------------------------------------------------------- |
| `security.md` | Escape/sanitize/nonce/prepare rules — blocking in review  |
| `i18n.md`     | Text-domain, translation functions, `.pot` generation     |
| `blocks.md`   | `registerBlockType` call shape and `block.php` conventions |
| `a11y.md`     | WCAG/RGAA AA — links, buttons, images, contrast           |

### Skills

Skills live at `.claude/skills/{name}.md` — **flat files, not subdirectories**. Use a subdirectory only if the skill requires companion files.

**File format:**

```markdown
---
name: skill-name
description: One-line description used to decide when to auto-trigger.
---

## When to invoke

## Procedure

## Output format
```

| Skill                   | Trigger                                   |
| ----------------------- | ----------------------------------------- |
| `sync-docs.md`          | Auto — whenever `.claude/` config changes |
| `a11y-links-buttons.md` | On-demand — `/a11y-links-buttons`         |
| `i18n-audit.md`         | On-demand — `/i18n-audit`                 |
| `block-audit.md`        | On-demand — `/block-audit`                |

### Agents

Sub-agents live at `.claude/agents/{name}.md`. The `wp-reviewer` agent performs a second-pass security/quality audit on theme diffs; it is invoked by the `review` skill or manually.

## Environments

| Env        | Purpose             | Branch      | Deploy                                          |
| ---------- | ------------------- | ----------- | ----------------------------------------------- |
| Local      | Dev on DDEV         | `feature/*` | —                                               |
| Staging    | Client preview / QA | `staging`   | `.github/workflows/deploy-staging.yml` (FTP)    |
| Production | Live                | `main`      | `.github/workflows/deploy-production.yml` (FTP) |

Integration branch: `development`. Flow: `feature/* → development → staging → main`.

## CI/CD (current)

- `.github/workflows/ci.yml` — PHP (lint + stan + test) + Node (lint + build) on every PR and push to `main` / `staging` / `development`.
- `.github/workflows/pr-checklist.yml` — fails the PR check while any item in the `## Checklist` section of the description is still unchecked. Re-runs on every PR-body edit.
- `.github/workflows/deploy-*.yml` — FTP deploy on push to `staging` / `main`.
- `.github/dependabot.yml` — weekly npm (`_dev/`) + GitHub Actions updates.
- `.github/CODEOWNERS` — single owner: `@valentin-grenier`.
- `bin/setup-branch-protection.sh` — idempotent `gh` CLI helper that enforces the CI gate and CODEOWNER review on `main`.

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
- **Native Gutenberg blocks only.** Blocks register themselves client-side via `registerBlockType` (no `block.json`); compiled bundles are enqueued from `dist/blocks/*/` by `inc/blocks.php`. No ACF dependency.
- **Single text-domain.** Source default is `fse-boilerplate` (per `style.css` header); `bin/setup.sh`
  substitutes it on client install.
