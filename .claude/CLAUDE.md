# CLAUDE.md — WP FSE Boilerplate

Session-start context for Claude Code on this repository.

## What this is

Studio Val boilerplate for a WordPress **Full Site Editing** (FSE) theme **and a companion
plugin scaffold**. Theme + plugin + DDEV + tooling only — WordPress core is present locally
but **not versioned**. Theme lives at `/wp-content/themes/theme-fse/`; the plugin scaffold at
`/wp-content/plugins/studioval-plugin-boilerplate/`.

The plugin scaffold is intentionally **blank** — Singleton bootstrap, one admin page with an
empty React mount, and the build chain. Add Settings/Frontend/REST/etc. as your plugin needs
them, instead of deleting demo code.

## Stack

- **WordPress** 6.0+, **PHP** 8.2+.
- **Webpack 5** + **Sass** — **not** `wp-scripts`. ⚠️ Do not propose a wp-scripts migration without explicit approval.
- **DDEV** (`.ddev/` versioned).
- **Native Gutenberg blocks** — JS-side `registerBlockType`, no `block.json`, no ACF dependency.
- **Composer**: WPCS (WordPress-Extra) + `phpstan` level 5 (target: 8) + PHPCompatibility 8.2.

## Key tree

```text
.
├── wp-content/
│   ├── themes/theme-fse/
│   │   ├── style.css        # Theme header (Theme Name, Version, Text Domain)
│   │   ├── theme.json       # Global FSE config (palette, typography, layout)
│   │   ├── functions.php    # require-only: glob(inc/*.php)
│   │   ├── inc/             # PHP logic split by concern (auto-loaded)
│   │   ├── templates/       # FSE templates (.html) — index, home, single, page, 404…
│   │   ├── parts/           # header.html, footer.html
│   │   ├── _dev/            # Source: SCSS, JS, blocks, webpack — edit here, not in dist/
│   │   └── dist/            # Build output (committed)
│   └── plugins/studioval-plugin-boilerplate/
│       ├── studioval-plugin-boilerplate.php  # Plugin header + bootstrap
│       ├── uninstall.php    # Stub for cleanup on plugin delete (add delete_option calls as needed)
│       ├── includes/        # OOP — Singleton trait, bootstrap, one admin-page class
│       ├── src/             # Source: JS (admin = React/Gutenberg) + admin SCSS
│       ├── dist/            # Webpack output (committed) — *.js, *.css, *.asset.php
│       ├── webpack.config.js # Independent build, runs from inside the plugin folder
│       └── languages/       # .pot lives here when generated
├── .claude/             # Claude Code config + team docs (ARCHITECTURE.md, CONVENTIONS.md)
├── .ddev/               # DDEV config (versioned)
├── bin/setup.sh         # Install: renames theme + plugin, substitutes placeholders, activates
└── .github/workflows/   # CI + FTP deploy workflows
```

## Code conventions

Run `composer ci` (lint → stan → test) before declaring backend work done. Daily commands: `docs/setup.md`.

- **Language**: code, comments, and all documentation in English.
- **Text-domains**: `studioval-boilerplate` (theme) + `studioval-plugin-boilerplate` (plugin). Both substituted by `bin/setup.sh`.
- **Theme prefix**: `sv_boilerplate_` — every function and custom hook. Substituted by `bin/setup.sh`.
- **Plugin prefix**: `Studioval_Plugin_Boilerplate_` (classes) / `STUDIOVAL_PLUGIN_BOILERPLATE_` (constants) / `studiovalPluginBoilerplate` (JS globals) / `svpb-` (CSS class prefix). All substituted by `bin/setup.sh`.
- **PHP — theme**: procedural only — no classes or namespaces in `inc/` without explicit approval.
- **PHP — plugin**: OOP, Singleton pattern. Every public class uses the `Studioval_Plugin_Boilerplate_Singleton` trait (`includes/trait-singleton.php`); each consumer declares `private function __construct()` and registers its hooks there. Bootstrap calls `ClassName::instance()` from `class-plugin.php`. **Never** `new ClassName()`.
- **Block namespace**: `studioval/{slug}` in the `registerBlockType` call.
- **Security**: every `inc/*.php` and `includes/*.php` opens with `ABSPATH` guard. Escape all output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`), sanitize all input, `$wpdb->prepare` for SQL, nonces on state-changing handlers. When the plugin grows a REST flow, use `wp_create_nonce('wp_rest')` exposed via `wp_localize_script` + `apiFetch.createNonceMiddleware` on the JS side.
- **i18n**: `__()`, `esc_html__()`, `_e()`, `_x()` with text-domain on every visible string. JS strings via `@wordpress/i18n` `__()`; admin scripts call `wp_set_script_translations()`.
- **Blocks**: one folder per block in `_dev/blocks/{name}/`; compiled bundles are auto-enqueued from `dist/blocks/{name}/` by `inc/blocks.php` (editor + front-end).
- **Cache-busting**: theme uses `filemtime()` on the compiled file. Plugin uses the version from the webpack-emitted `dist/{entry}.asset.php` manifest (via `@wordpress/dependency-extraction-webpack-plugin`).

## Files never to modify

- `wp-config*.php` — DB config and salts.
- `/wp-content/themes/theme-fse/dist/**` — build output; use `npm run build` only.
- `/wp-content/plugins/studioval-plugin-boilerplate/dist/**` — same rule, `npm run build` from inside the plugin folder.

## Git workflow

**This repo (template):** `main` = the pristine base (default branch), `demo` = an installed example. Neither deploys — the FTP deploy workflows are guarded off here (`if: github.repository != …`).

**Generated client projects:** `bin/setup.sh` commits on `main` and creates `staging` + `development`. There, `main` = production and `staging` = pre-prod (both FTP-deployed on push); flow is `feature/* → development → staging → main`.

GitHub Actions gates PHP lint/stan/test + Node lint/build on every PR (template and client projects alike).

## Known pitfalls

- **Theme not directly activatable**: run `bin/setup.sh` first to substitute `boilerplate` with the project slug.
- **~18 non-blocking phpcs warnings**: `file_get_contents`/`file_put_contents`/`wp_redirect` alternative suggestions, unused-param notes on required WP hook signatures, commented code in `dashboard.php`.

## Response language

Default: **French**. Switch to English when I write in English.

## Pointers

- **Commits and PRs**: use the `git-open-pr` skill (build → commit → push → PR, never merge).
- **PHPStan level bumps**: use the `phpstan-bump` skill.
- **Block authoring**: `docs/blocks.md`.
- **Naming, security, i18n, a11y, blocks**: `.claude/rules/`. **Git & tooling**: `.claude/CONVENTIONS.md`.
