# Modernization Implementation Tracker

This document tracks the "Claude-Code-ready" modernization of the Studio Val WordPress FSE boilerplate.
It is the live companion to the approved plan at `~/.claude/plans/misty-doodling-dahl.md` and is updated
after every batch.

All new documentation added by this modernization is in English. Existing French docs
(`.claude/CLAUDE.md`, `README.md`) are intentionally left in French to match the historical project
convention; only new team-level technical docs switch to English.

---

## Audit initial

Baseline state vs. the 10-section "Claude-Code-ready" checklist. Legend: ✅ compliant — 🟡 partial — ❌ absent.

| # | Section                        | State | Diagnosis                                                                                                                       |
|---|--------------------------------|:-----:|---------------------------------------------------------------------------------------------------------------------------------|
| 1 | Documentation                  | 🟡    | `.claude/CLAUDE.md` + `README.md` are solid. Missing (added in Batch 1): `.claude/ARCHITECTURE.md`, `.claude/BLOCKS.md`, `.claude/CONVENTIONS.md`, root `CHANGELOG.md`. |
| 2 | `.claude/` configuration       | 🟡    | `settings.json` has permissions but no `hooks`. No `rules/`, `agents/`, `skills/`, `commands/`, `lessons.md`. No `.mcp.json`.    |
| 3 | Verification mechanisms        | ❌    | `composer lint` references `--standard=WordPress` with no `phpcs.xml`. No phpstan, eslint, stylelint, prettier, editorconfig, phpunit.xml, smoke.sh. |
| 4 | FSE structure                  | 🟡    | `style.css` header complete, `theme.json` has `$schema`, `functions.php` require-only. Missing: `patterns/`, `languages/` (.pot), `$schema` in `block.json`. **Defect:** 12 of 14 `inc/*.php` lack `ABSPATH` guard. |
| 5 | Claude Code hooks              | ❌    | No hooks configured.                                                                                                            |
| 6 | Conventions                    | 🟡    | `studio_` prefix applied consistently, but **4 different text-domains** in use (`fse-boilerplate`, `studio-val`, `studio-theme`, `theme-name`). |
| 7 | Gitignore & secrets            | ✅    | `.gitignore` covers core WP, vendor, node_modules, `.env`, `auth.json`. `git log` history clean. `auth.json.example` present. Only `.env.example` missing. |
| 8 | Reproducible dev env           | 🟡    | DDEV committed. Missing: `.nvmrc`, composer platform PHP 8.2, committed locks (known limitation). README quickstart present.   |
| 9 | CI/CD                          | 🟡    | `deploy-staging.yml` + `deploy-production.yml` + `dependabot.yml` + `CODEOWNERS` in place. Missing: PR lint/test, Claude Code Action auto-review, documented branch protection. |
| 10| Meta                           | ❌    | No `lessons.md`, no monthly audit routine, plugin packaging deferred.                                                           |

---

## Decisions log (plan-mode Q&A)

1. **Docs language** → new docs in English; existing `CLAUDE.md` / `README.md` stay in French.
2. **Existing defects** → fix now (ABSPATH guards + text-domain normalization).
3. **PHP tooling** → full checklist: phpcs `WordPress-Extra`, phpstan level 5 + `szepeviktor/phpstan-wordpress`, composer `platform.php = 8.2`, `Requires PHP: 8.2` in `style.css`.
4. **Plugin packaging** → deferred (documented in Future work).
5. **Default prefixes** → updated: text-domain `studioval-boilerplate`, function/hook prefix `sv_boilerplate_`, PHP namespace `StudioVal\Boilerplate\`, block namespace `studioval/{name}`. `bin/setup.sh` substitutes the `boilerplate` token → client slug.
6. **Claude hooks** → all 5 types (PostToolUse, PreToolUse, SessionStart, PreCompact, Notification) with minimal implementations.
7. **Branch protection** → documented + provided as a `bin/setup-branch-protection.sh` (`gh` CLI) helper.

---

## Batches

- [x] **1. Docs & reproducibility** — `.claude/ARCHITECTURE.md`, `.claude/BLOCKS.md`, `.claude/CONVENTIONS.md`, `.claude/IMPLEMENTATION.md`, `CHANGELOG.md`, `.editorconfig`, `.nvmrc`, `.env.example`; docs-language note in `.claude/CLAUDE.md`.
- [ ] **2. PHP tooling** — `phpcs.xml.dist`, `phpstan.neon.dist`, `phpunit.xml.dist`; update `composer.json` (platform 8.2, dev deps, scripts); bump `style.css` `Requires PHP`.
- [ ] **3. JS/CSS tooling** — `_dev/.eslintrc.json`, `.stylelintrc.json`, `.prettierrc`, `.prettierignore`; update `_dev/package.json` (deps + scripts).
- [ ] **4. Fix pre-existing defects** — add `ABSPATH` guard to 12 files in `inc/`; normalize 4 text-domains to `studioval-boilerplate`; update `style.css` `Text Domain` + `Domain Path`.
- [ ] **5. Prefix + namespace migration** — `studio_` → `sv_boilerplate_`; `StudioVal\WPBoilerplate\` → `StudioVal\Boilerplate\`; update block namespaces, `composer.json` autoload, `bin/setup.sh` substitutions, `.github/copilot-instructions.md`.
- [ ] **6. FSE structure gaps** — create `patterns/hero-centered.php`; create `languages/studioval-boilerplate.pot`; add `$schema` to all `block.json`.
- [ ] **7. Claude hooks & `.claude/` layout** — expand `settings.json` with 5 hook types; create `rules/`, `agents/wp-reviewer.md`, `commands/smoke.md`, `lessons.md`, `skills/.gitkeep`; add `.mcp.json`.
- [ ] **8. Verification script** — `bin/smoke.sh` (DB check + theme status + curl + lint + stan + build).
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
