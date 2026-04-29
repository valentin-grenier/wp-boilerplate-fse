# CLAUDE.md — WP FSE Boilerplate

Session-start context for Claude Code on this repository.

## What this is

Studio Val boilerplate for a WordPress **Full Site Editing** (FSE) theme. Theme + DDEV + tooling
only — WordPress core is present locally but **not versioned**. Theme lives at
`/wp-content/themes/theme-fse/`.

## Stack

- **WordPress** 6.0+, **PHP** 8.2+.
- **Webpack 5** + **Sass** — **not** `wp-scripts`. ⚠️ Do not propose a wp-scripts migration without explicit approval.
- **DDEV** (`.ddev/` versioned).
- **Native Gutenberg blocks** — JS-side `registerBlockType`, no `block.json`, no ACF dependency.
- **Composer**: WPCS (WordPress-Extra) + `phpstan` level 5 (target: 8) + PHPCompatibility 8.2.

## Key tree

```text
.
├── wp-content/themes/theme-fse/
│   ├── style.css        # Theme header (Theme Name, Version, Text Domain)
│   ├── theme.json       # Global FSE config (palette, typography, layout)
│   ├── functions.php    # require-only: glob(inc/*.php)
│   ├── inc/             # PHP logic split by concern (auto-loaded)
│   ├── templates/       # FSE templates (.html) — index, home, single, page, 404…
│   ├── parts/           # header.html, footer.html
│   ├── _dev/            # Source: SCSS, JS, blocks, webpack — edit here, not in dist/
│   └── dist/            # Build output (committed)
├── .claude/             # Claude Code config + team docs (BLOCKS.md, CONVENTIONS.md)
├── .ddev/               # DDEV config (versioned)
├── bin/setup.sh         # Install: renames theme, substitutes placeholders, activates
└── .github/workflows/   # CI + FTP deploy workflows
```

## Code conventions

Run `composer ci` (lint → stan → test) before declaring backend work done. Daily commands: `docs/setup.md`.

- **Language**: code, comments, and all documentation in English.
- **Text-domain**: `studioval-boilerplate` — every `__()`, `esc_html__()`, every i18n string in block JS metadata.
- **Prefix**: `sv_boilerplate_` — every function and custom hook. Substituted by `bin/setup.sh`.
- **PHP**: procedural only — no classes or namespaces in `inc/` without explicit approval.
- **Block namespace**: `studioval/{slug}` in the `registerBlockType` call.
- **Security**: every `inc/*.php` opens with `ABSPATH` guard. Escape all output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`), sanitize all input, `$wpdb->prepare` for SQL, nonces on state-changing handlers.
- **i18n**: `__()`, `esc_html__()`, `_e()`, `_x()` with text-domain on every visible string.
- **Blocks**: one folder per block in `_dev/blocks/{name}/`; compiled bundles are auto-enqueued from `dist/blocks/{name}/` by `inc/blocks.php` (editor + front-end).
- **Cache-busting**: `filemtime()` on the compiled file — never hardcode a version.

## Files never to modify

- `wp-config*.php` — DB config and salts.
- `/wp-content/themes/theme-fse/dist/**` — build output; use `npm run build` only.

## Git workflow

Branches (`bin/setup.sh` creates them): `main` (production, protected) · `staging` (pre-prod, FTP deploy on push) · `development` (CI) · `feature/*`.

GitHub Actions gates PHP lint/stan/test + Node lint/build on every PR; deploys via FTP on push to `staging` / `main`.

## Known pitfalls

- **Theme not directly activatable**: run `bin/setup.sh` first to substitute `boilerplate` with the project slug.
- **~18 non-blocking phpcs warnings**: `file_get_contents`/`file_put_contents`/`wp_redirect` alternative suggestions, unused-param notes on required WP hook signatures, commented code in `dashboard.php`.

## Response language

Default: **French**. Switch to English when I write in English.

## Pointers

- **Commits and PRs**: use the `git-open-pr` skill (build → commit → push → PR, never merge).
- **PHPStan level bumps**: use the `phpstan-bump` skill.
- **Block authoring**: `.claude/BLOCKS.md`.
- **Naming, security, i18n, git details**: `.claude/CONVENTIONS.md`.
