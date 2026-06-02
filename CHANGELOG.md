# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the version numbers follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Consolidated Claude Code docs to a single source per topic: merged the block guide into `docs/blocks.md` (removed `.claude/BLOCKS.md`), trimmed `CONVENTIONS.md` to Git + tooling, cut and corrected `ARCHITECTURE.md`, and deduplicated `rules/components.md` against `rules/security.md`.

### Fixed

- Stale doc references: `block.json` mentions (the theme has none — blocks register via `registerBlockType`), the `fse-boilerplate` / `arnauneprim` text-domain leftovers, and phantom `bin/cleanup.sh` / `IMPLEMENTATION.md` paths in `ARCHITECTURE.md` and `docs-sync`.

## [2.0.0] — 2026-06-02

### Added

- Team docs in `.claude/`: `ARCHITECTURE.md`, `BLOCKS.md`, `CONVENTIONS.md`, `IMPLEMENTATION.md` (Claude-only workflow — co-located with `CLAUDE.md` for context surfacing).
- Root: `CHANGELOG.md`.
- Reproducibility: `.editorconfig`, `.nvmrc`, `.env.example`.
- PHP tooling: `phpcs.xml.dist` (WordPress-Extra), `phpstan.neon.dist` (level 5 + `szepeviktor/phpstan-wordpress`), `phpunit.xml.dist`.
- Frontend tooling: `_dev/.eslintrc.json`, `_dev/.stylelintrc.json`, `_dev/.prettierrc`, `_dev/.prettierignore`.
- FSE: `patterns/` with starter pattern, `languages/studioval-boilerplate.pot`.
- Claude Code: PostToolUse / PreToolUse / SessionStart / PreCompact / Notification hooks; `.claude/rules/`, `.claude/agents/wp-reviewer.md`, `.claude/commands/smoke.md`, `.claude/lessons.md`; `.mcp.json` template.
- Verification: `bin/smoke.sh`.
- CI: `.github/workflows/ci.yml` (lint + stan + build on PR), `.github/workflows/pr-checklist.yml` (fails the PR while any `## Checklist` box is unchecked).
- Branch protection helper: `bin/setup-branch-protection.sh`.

### Changed

- Text-domain normalized across the theme to `studioval-boilerplate` (was mixed: `fse-boilerplate`, `studio-val`, `studio-theme`, `theme-name`).
- Function/hook prefix migrated from `studio_` to `sv_boilerplate_`.
- PHP namespace migrated from `StudioVal\WPBoilerplate\` to `StudioVal\Boilerplate\`.
- Block namespace migrated to `studioval/{name}`.
- Blocks migrated from `block.json` auto-discovery to client-side `registerBlockType('studioval/{slug}')` registration — no `block.json`.
- `composer.json` platform bumped to PHP 8.2; `style.css` `Requires PHP` bumped to 8.2.
- `bin/setup.sh` substitution table updated to the new token scheme.

### Removed

- ACF Pro dependency (`auth.json`) — blocks are now native Gutenberg, registered via `registerBlockType`; no ACF.

### Fixed

- 12 of 14 `inc/*.php` files were missing the `if ( ! defined( 'ABSPATH' ) ) { exit; }` guard — added.

## [1.0.0] — 2025

Initial public release of the Studio Val WordPress FSE boilerplate.

### Added

- FSE theme scaffold at `wp-content/themes/theme-fse/`: `theme.json`, `style.css`, `functions.php`, `templates/`, `parts/`, `styles/`.
- Modular PHP in `inc/` (theme setup, assets, security, performance, dashboard, comments, blocks).
- Webpack 5 build pipeline under `_dev/` with BrowserSync and `make-block` scaffolder.
- DDEV local environment config.
- GitHub Actions FTP deploys to staging and production.
- ACF Pro integration via `auth.json`.
- Automated `bin/setup.sh` for client-project bootstrapping.

[Unreleased]: https://github.com/valentin-grenier/wp-boilerplate-fse/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/valentin-grenier/wp-boilerplate-fse/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/valentin-grenier/wp-boilerplate-fse/releases/tag/v1.0.0
