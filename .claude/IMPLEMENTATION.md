# Modernization Implementation Tracker

This document tracks the "Claude-Code-ready" modernization of the Studio Val WordPress FSE boilerplate.
It is the live companion to the approved plan at `~/.claude/plans/misty-doodling-dahl.md` and is updated
after every batch.

All documentation is in English, including team docs under `.claude/` and the root `README.md`
/ `CHANGELOG.md`. (`.claude/CLAUDE.md` was originally kept in French; it was translated to English
mid-modernization so every Claude-facing doc uses the same language.)

---

## Audit initial

Baseline state vs. the 10-section "Claude-Code-ready" checklist. Legend: ✅ compliant — 🟡 partial — ❌ absent.

| # | Section                        | State | Diagnosis                                                                                                                       |
|---|--------------------------------|:-----:|---------------------------------------------------------------------------------------------------------------------------------|
| 1 | Documentation                  | 🟡    | `.claude/CLAUDE.md` + `README.md` are solid. Missing (added in Batch 1): `.claude/ARCHITECTURE.md`, `.claude/BLOCKS.md`, `.claude/CONVENTIONS.md`, root `CHANGELOG.md`. |
| 2 | `.claude/` configuration       | ✅    | `settings.json` has permissions + 4 hook types (SessionStart, PostToolUse, PreCompact, Notification). `rules/`, `agents/`, `commands/`, `skills/`, `lessons.md` present. `.mcp.json` template shipped. |
| 3 | Verification mechanisms        | ✅    | phpcs (WordPress-Extra), phpstan level 5 + WP extension, phpunit, ESLint, Stylelint, Prettier, and `bin/smoke.sh` end-to-end gate. `composer ci` green. |
| 4 | FSE structure                  | ✅    | `style.css` header complete, `theme.json` has `$schema`, `functions.php` require-only, 14/14 `inc/*.php` guarded, `patterns/` seeded with a starter, `languages/studioval-boilerplate.pot` stub committed, `block.json` carries `$schema` + `textdomain`. |
| 5 | Claude Code hooks              | ✅    | 4 hook types wired: SessionStart (banner), PostToolUse (Edit/Write → phpcs / prettier), PreCompact (append to lessons.md), Notification (bell). PreToolUse skipped — `permissions.deny` already handles the sensitive-file block. |
| 6 | Conventions                    | 🟡    | Text-domain normalized to `studioval-boilerplate` across the theme. `studio_` prefix still present (migrated in Batch 5). |
| 7 | Gitignore & secrets            | ✅    | `.gitignore` covers core WP, vendor, node_modules, `.env`, `auth.json`. `git log` history clean. `auth.json.example` present. Only `.env.example` missing. |
| 8 | Reproducible dev env           | 🟡    | DDEV committed. Missing: `.nvmrc`, composer platform PHP 8.2, committed locks (known limitation). README quickstart present.   |
| 9 | CI/CD                          | 🟡    | `deploy-staging.yml` + `deploy-production.yml` + `dependabot.yml` + `CODEOWNERS` in place. Missing: PR lint/test, Claude Code Action auto-review, documented branch protection. |
| 10| Meta                           | 🟡    | `lessons.md` stub committed, monthly-audit routine documented at the bottom of this file, plugin packaging deferred.             |

---

## Decisions log (plan-mode Q&A)

1. **Docs language** → all docs in English. Initially planned to keep `.claude/CLAUDE.md` in French; decision revised mid-modernization so every Claude-facing doc uses the same language.
2. **Existing defects** → fix now (ABSPATH guards + text-domain normalization).
3. **PHP tooling** → full checklist: phpcs `WordPress-Extra`, phpstan level 5 + `szepeviktor/phpstan-wordpress`, composer `platform.php = 8.2`, `Requires PHP: 8.2` in `style.css`.
4. **Plugin packaging** → deferred (documented in Future work).
5. **Default prefixes** → updated: text-domain `studioval-boilerplate`, function/hook prefix `sv_boilerplate_`, PHP namespace `StudioVal\Boilerplate\`, block namespace `studioval/{name}`. `bin/setup.sh` substitutes the `boilerplate` token → client slug.
6. **Claude hooks** → all 5 types (PostToolUse, PreToolUse, SessionStart, PreCompact, Notification) with minimal implementations.
7. **Branch protection** → documented + provided as a `bin/setup-branch-protection.sh` (`gh` CLI) helper.

---

## Batches

- [x] **1. Docs & reproducibility** — `.claude/ARCHITECTURE.md`, `.claude/BLOCKS.md`, `.claude/CONVENTIONS.md`, `.claude/IMPLEMENTATION.md`, `CHANGELOG.md`, `.editorconfig`, `.nvmrc`, `.env.example`; docs-language note in `.claude/CLAUDE.md`. Then realigned to current-state truth (each subsequent batch updates the relevant doc lines as it ships).
- [x] **2. PHP tooling** — `phpcs.xml.dist` (WordPress-Extra + text-domain sniff for `fse-boilerplate` + PHPCompatibility WP 8.2), `phpstan.neon.dist` (level 5 + `szepeviktor/phpstan-wordpress`), `phpunit.xml.dist` (+ `tests/.gitkeep`); `composer.json` bumped `php` to `>=8.2`, pinned `config.platform.php`, added `phpstan/phpstan` + `szepeviktor/phpstan-wordpress`, simplified `lint`/`lint:fix`, added `stan` + `ci`; `style.css` `Requires PHP` → `8.2`. Docs updated: `.claude/CLAUDE.md` (Stack, Essential commands, Known pitfalls), `.claude/CONVENTIONS.md` PHP, `.claude/ARCHITECTURE.md` (tree + Developer workflow).
- [x] **3. JS/CSS tooling** — `_dev/.eslintrc.json` (`@wordpress/eslint-plugin/recommended`), `_dev/.stylelintrc.json` (`@wordpress/stylelint-config/scss`), `_dev/.prettierrc` (tabs, print-width 100, single quotes, ES5 commas, LF), `_dev/.prettierignore`. `_dev/package.json` gained `eslint`, `@wordpress/eslint-plugin`, `stylelint`, `@wordpress/stylelint-config`, `prettier` in `devDependencies` (versions pinned to current stable lines) and new scripts: `lint:js`, `lint:js:fix`, `lint:css`, `lint:css:fix`, `lint` (runs both), `format` (prettier --write). Docs updated: `.claude/CONVENTIONS.md` CSS + JS sections rewritten plus a new Formatting section; `.claude/ARCHITECTURE.md` `_dev/` tree extended.
- [x] **4. Fix pre-existing defects** — ABSPATH guard added to 12 `inc/*.php` files (all 14 now guarded). 38 text-domain occurrences (across `post-types.php`, `block-categories.php`, `security.php`, `dashboard.php`) normalized to `studioval-boilerplate`; `style.css` `Text Domain` + `Domain Path` updated; `phpcs.xml.dist` sniff updated; `bin/setup.sh` substitution table updated; `_dev/scripts/make-block.js` text-domain args updated. Lint: 40 → 5 errors remaining (triage batch). Docs updated: `.claude/CLAUDE.md` (Text-domain + WP security bullets), `.claude/CONVENTIONS.md` (Text-domain + Security sections), `.claude/BLOCKS.md` (block.json textdomain reference).
- [x] **5. Prefix + namespace migration** — 76 `studio_` occurrences across 14 `inc/*.php` files renamed to `sv_boilerplate_`; `composer.json` PSR-4 autoload `StudioVal\WPBoilerplate\` → `StudioVal\Boilerplate\`; 5 remaining `theme-name` placeholders in `_dev/scripts/make-block.js` (block namespace, category, CSS class) updated to `studioval`; `bin/setup.sh` obsolete `wp-block-theme-name-` sed removed and the block-namespace-stays-constant policy documented inline; `.github/copilot-instructions.md` synced (tech stack PHP 8.2+, function prefix, namespace, text-domain). Lint + stan unchanged (no regressions). Docs updated: `.claude/CLAUDE.md` (Hook prefix, PHP namespace, Known pitfalls), `.claude/CONVENTIONS.md` (PHP function prefix, PHP namespace sections).
- [x] **5b. Triage — remaining lint + stan fixes** — phpcs: 3 `$icon_url` echoes in `dashboard.php` wrapped in `esc_url()`; 2 Yoda conditions flipped (`block-settings.php` line 40, `comments.php` line 35); `wp_redirect` → `wp_safe_redirect` in `comments.php`. phpstan: `add_filter( 'init', ... )` → `add_action` in `block-categories.php`; `@return void` docblock → `@return array` for `sv_boilerplate_register_blocks_categories`; `add_action( 'register_block_type_args', ... )` → `add_filter` in `block-settings.php`; callback signature + `accepted_args` alignment in `comments.php` for `sv_boilerplate_disable_comments_status` and `sv_boilerplate_hide_existing_comments`. Result: `composer ci` is fully green (0 phpcs errors, 0 phpstan errors). 18 phpcs warnings remain (non-blocking). Docs updated: `.claude/CLAUDE.md`, `.claude/CONVENTIONS.md`, `.claude/ARCHITECTURE.md` Developer workflow to reflect green state.
- [x] **6. FSE structure gaps** — `patterns/hero-centered.php` starter pattern (full-width group with heading, subheading, centered CTA button; registers under `studioval-boilerplate` pattern category; every user-visible string is wrapped in `esc_html_x`). `languages/studioval-boilerplate.pot` stub (regenerate with `ddev wp i18n make-pot` before release). `_dev/blocks/block/block.json` extended with `$schema`, `apiVersion: 3`, `textdomain: studioval-boilerplate`, and `category: studioval` (was `layout` — the theme's own category registered by `inc/block-categories.php`).
- [x] **7. Claude hooks & `.claude/` layout** — 4 hooks wired in `settings.json` (SessionStart, PostToolUse, PreCompact, Notification) backed by scripts under `.claude/hooks/`. PreToolUse intentionally omitted — `permissions.deny` already covers the sensitive-file guard with less friction than a custom hook. `.claude/rules/` seeded with `security.md`, `i18n.md`, `blocks.md`. `.claude/agents/wp-reviewer.md` authored as a review subagent. `.claude/commands/smoke.md` added (depends on Batch 8's `bin/smoke.sh`). `.claude/skills/sync-docs/SKILL.md` added — the auto-trigger skill that audits `.claude/` team docs for drift whenever Claude automation changes. `.claude/lessons.md` stub created. `.mcp.json` template at repo root (Notion server commented out, template for client forks).
- [x] **8. Verification script** — `bin/smoke.sh` runs the end-to-end gate: `ddev wp db check`, `ddev wp theme status theme-fse`, homepage `curl -sfI`, `composer lint` / `stan` / `test`, and the frontend `npm run lint:js` / `lint:css` / `build`. Supports `--fast` (skip npm build) and `--no-ddev` (CI mode). Exits non-zero on the first failure, prints a compact pass/fail summary. `.claude/commands/smoke.md` (from Batch 7) now has an executable target.
- [ ] **9. CI/CD** — `.github/workflows/ci.yml`, `.github/workflows/claude-review.yml`, `bin/setup-branch-protection.sh`.
- [ ] **10. Meta & tracking** — finalize `.claude/IMPLEMENTATION.md`, document monthly audit routine.

Each batch lands as a single Conventional Commit (`feat(tooling):`, `fix(theme):`, `chore(claude):`, …) so the history narrates the modernization.

---

## Future work (out of scope for this effort)

- **Claude Code plugin packaging** — turn the boilerplate into an installable Claude Code plugin under `studioval/fse-boilerplate` (manifest at `.claude-plugin/plugin.json`, restructure so it works both as a repo-to-clone and as `claude plugin install`).
- **Webpack → `@wordpress/scripts` migration** — explicit user-blocked per `.claude/CLAUDE.md`; revisit when the trade-off is clearer.
- **Commit lockfiles** — currently `composer.lock` and `package-lock.json` are gitignored (reproducibility limitation flagged in `.claude/CLAUDE.md`).
- **Pre-commit hook** (husky-style `lint-staged`) to enforce lint gates locally before CI.
- **PHPUnit tests** — this effort scaffolds `phpunit.xml.dist` but ships no tests. Add integration tests against DDEV MySQL with `yoast/phpunit-polyfills` when tooling bandwidth allows.

---

## Monthly audit routine

On the first working day of each month, open an "Audit Claude-Code-ready" issue and walk the 10-section checklist:

1. Re-grep for hook prefix leakage (`studio_`, mixed text-domains) — catches regressions on new features.
2. Re-run `composer stan` at level 5 — bump one level when the codebase is clean.
3. Check `.claude/lessons.md` for recurring patterns; promote stable ones to `.claude/rules/*.md`.
4. Review `.github/workflows/` runtimes on the last 30 PRs; prune slow jobs.
5. `npm outdated` and `composer outdated -D` in both repo root and `_dev/`. Open a Dependabot-grouped PR if needed.
6. Skim `CHANGELOG.md` `Unreleased` section; if > 3 entries, cut a minor release.
7. Revisit "Future work" above; move one item to in-flight if capacity allows.

Time budget: ~30 min. Outcome: one commit or one short issue with the month's findings.
