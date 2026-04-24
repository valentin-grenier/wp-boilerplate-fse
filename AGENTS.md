# AGENTS.md

Entry point for agent-based coding assistants working in this repository.

## Source of truth

All contributors — human or AI — follow the same conventions. The primary context is
[`.claude/CLAUDE.md`](.claude/CLAUDE.md) (French). The technical specs below are in English and are
shared across all agent runners:

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — tree, responsibilities, build pipeline, deploy flow.
- [`BLOCKS.md`](BLOCKS.md) — ACF block authoring and registration pipeline.
- [`CONVENTIONS.md`](CONVENTIONS.md) — prefixes, namespaces, security, i18n, git.
- [`CHANGELOG.md`](CHANGELOG.md) — Keep-a-Changelog history.

## Supported agent runners

| Runner               | Config file                                               | Notes                                                |
|----------------------|-----------------------------------------------------------|------------------------------------------------------|
| **Claude Code**      | [`.claude/CLAUDE.md`](.claude/CLAUDE.md), [`.claude/settings.json`](.claude/settings.json) | Hooks enforce lint-on-save; rules in [`.claude/rules/`](.claude/rules/). |
| **GitHub Copilot**   | [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | Kept in sync with `CLAUDE.md`.                       |
| **Cursor / Aider**   | Read the files above in order                              | No dedicated config file — read CLAUDE.md + this file first. |

## Non-negotiables

Any agent editing this repo must respect these, regardless of runner:

1. **Security guards** — every `inc/*.php` file starts with `if ( ! defined( 'ABSPATH' ) ) { exit; }`.
2. **Escape output, sanitize input, nonce actions, `$wpdb->prepare` queries.** See `CONVENTIONS.md`.
3. **One text-domain** (`studioval-boilerplate`). Never introduce a second.
4. **No edits under** `wp-admin/`, `wp-includes/`, `wp-config*.php`, `vendor/`, `node_modules/`, `dist/` (compiled output — edit sources under `_dev/`).
5. **No `wp-scripts` migration proposals** without explicit user approval (see `.claude/CLAUDE.md` Stack section).
6. **Conventional Commits** for every commit.

## Before opening a PR

Run locally:

```bash
composer ci            # lint + stan + test
cd wp-content/themes/theme-fse/_dev && npm run lint:js && npm run lint:css && npm run build
bin/smoke.sh           # DDEV-backed end-to-end smoke check
```

Both `ci.yml` and `claude-review.yml` run on PR. Do not merge with red checks.
