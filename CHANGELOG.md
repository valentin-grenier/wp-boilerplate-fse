# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the version numbers follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Team docs in `.claude/`: `ARCHITECTURE.md`, `BLOCKS.md`, `CONVENTIONS.md`, `IMPLEMENTATION.md` (Claude-only workflow — co-located with `CLAUDE.md` for context surfacing).
- Root: `CHANGELOG.md`.
- Reproducibility: `.editorconfig`, `.nvmrc`, `.env.example`.
- PHP tooling: `phpcs.xml.dist` (WordPress-Extra), `phpstan.neon.dist` (level 5 + `szepeviktor/phpstan-wordpress`), `phpunit.xml.dist`.
- Frontend tooling: `_dev/.eslintrc.json`, `_dev/.stylelintrc.json`, `_dev/.prettierrc`, `_dev/.prettierignore`.
- FSE: `patterns/` with starter pattern, `languages/studioval-boilerplate.pot`, `$schema` in every `block.json`.
- Claude Code: PostToolUse / PreToolUse / SessionStart / PreCompact / Notification hooks; `.claude/rules/`, `.claude/agents/wp-reviewer.md`, `.claude/commands/smoke.md`, `.claude/lessons.md`; `.mcp.json` template.
- Verification: `bin/smoke.sh`.
- CI: `.github/workflows/ci.yml` (lint + stan + build on PR).
- Branch protection helper: `bin/setup-branch-protection.sh`.

### Changed
- Text-domain normalized across the theme to `studioval-boilerplate` (was mixed: `fse-boilerplate`, `studio-val`, `studio-theme`, `theme-name`).
- Function/hook prefix migrated from `studio_` to `sv_boilerplate_`.
- PHP namespace migrated from `StudioVal\WPBoilerplate\` to `StudioVal\Boilerplate\`.
- Block namespace migrated to `studioval/{name}`.
- `composer.json` platform bumped to PHP 8.2; `style.css` `Requires PHP` bumped to 8.2.
- `bin/setup.sh` substitution table updated to the new token scheme.

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

[Unreleased]: https://github.com/valentin-grenier/wp-boilerplate-fse/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/valentin-grenier/wp-boilerplate-fse/releases/tag/v1.0.0
