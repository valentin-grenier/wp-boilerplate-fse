# `bin/setup.sh` — Phase 1 audit

**Scope:** `bin/setup.sh` (1035 lines) and everything it rewrites.
**Status:** audit only — no code changed.
**Branch:** `fix/setup-script`.

> Note on location: the brief says "setup.sh at the root". The script lives at
> `bin/setup.sh`; there is no root-level `setup.sh`. Everything below refers to
> `bin/setup.sh`.

---

## 1. Responsibilities, in execution order

| # | Lines | Responsibility |
|---|-------|----------------|
| 1 | 9–25 | TTY-aware colour palette, `LOG_DELAY=0.05` artificial pacing |
| 2 | 28–174 | Logging (`log_step/info/success/warning/error`), timestamped file log under `logs/`, spinner, run counters, final summary |
| 3 | 176–191 | `sed_inplace` (BSD/GNU portability), `slug_to_display_name` |
| 4 | 193–248 | `update_theme_text_domain` — rewrites `'studioval-boilerplate'` in theme PHP/JS, pattern headers, the phpcs text-domain allowlist, renames + rewrites + recompiles `languages/` |
| 5 | 250–325 | `update_theme_info` — `style.css` header (Name/URI/Text Domain), `inc/block-categories.php`, `_dev/scripts/make-block.js`, then calls #4 |
| 6 | 327–491 | Plugin scaffold: derive 7 identifier forms, substitute across PHP/JS/JSON/SCSS, rename folder + main file, patch `phpcs.xml.dist` + `phpstan.neon.dist` + `.gitignore` for the plugin |
| 7 | 493–534 | `update_workflow_files` — theme path in `deploy-staging.yml` / `deploy-production.yml`, deletes the template deploy guard |
| 8 | 536–571 | `finalize_project_branches` — `git add -A` + commit, create `staging` + `development` |
| 9 | 573–630 | Config defaults, flag parsing, `--help` |
| 10 | 632–645 | Runtime detection (`ddev wp` / `wp` / `cmd //c wp`) + WP-CLI presence check |
| 11 | 647–702 | Logging init, `wp-config.php` check, core-files check, `wp core is-installed`, "pristine boilerplate" guard |
| 12 | 704–804 | Theme auto-detect → prompt → validate slug → `mv` → #5 → #7 |
| 13 | 806–826 | Plugin prompt → validate slug → #6 |
| 14 | 828–896 | Install 5 dev plugins (activated) + 8 prod plugins (not activated) from wordpress.org |
| 15 | 898–928 | Activate the renamed theme, verify |
| 16 | 930–1007 | Create a French "Accueil" page, set it as static front page, force-delete "Sample Page" |
| 17 | 1009–1010 | #8 |
| 18 | 1012–1035 | Success message + summary |

That is **18 distinct responsibilities in one flat top-level script** — renaming, string substitution, CI-config rewriting, package management, content seeding, and git branching all in the same file with no separation.

---

## 2. Failure modes, by severity

### S1 — Critical: produces a broken project

**S1.1 — The theme rename breaks phpcs, phpstan, phpunit and CI. Nothing rewrites them.**

`update_plugin_lint_configs` (400–429) rewrites the *plugin* path in `phpcs.xml.dist` and `phpstan.neon.dist`. There is **no equivalent for the theme**. `update_theme_text_domain` only touches the phpcs `<element value="…"/>` text-domain, never a path. After `theme-fse → my-project`:

- `phpcs.xml.dist:22` — `<file>wp-content/themes/theme-fse/</file>` → nonexistent path
- `phpstan.neon.dist` `paths:` / `excludePaths:` → nonexistent path
- `phpunit.xml.dist:33` — coverage `directory` → nonexistent path
- `.github/workflows/ci.yml:57` — `working-directory: wp-content/themes/theme-fse/_dev` → **the frontend CI job fails on the first PR**
- `.github/dependabot.yml:4` — `directory: "/wp-content/themes/theme-fse/_dev"` → Dependabot silently stops
- `bin/smoke.sh` (hardcodes `theme-fse` **and** `wp-boilerplate-fse.ddev.site`), `bin/reset-theme-json.sh:7`

`composer ci` — the gate the conventions require before declaring backend work done — is red from minute one of every generated project.

*This is the real defect behind the "PSR-4 autoload path breaks after rename" item. See §3.1.*

**S1.2 — The renamed theme's `dist/` silently drops out of git.**

`.gitignore` ignores `wp-content/themes/**/dist/` and re-includes only `!wp-content/themes/theme-fse/dist/` (plus a `theme-fse/dist/**/*.map` rule). `update_plugin_gitignore` (435–453) patches **only** the plugin lines. After the rename, the theme's committed build output is ignored. Since `dist/` is committed by convention and the FTP deploy ships from the checkout, **staging and production deploy a theme with no compiled CSS/JS** — and nobody notices locally, because the files still exist on disk.

**S1.3 — The `sv_boilerplate_` function prefix is never substituted.**

`.claude/CLAUDE.md` states the theme prefix `sv_boilerplate_` is "Substituted by `bin/setup.sh`". It is not — `grep -n sv_boilerplate bin/setup.sh` returns nothing. **95 occurrences across 16 files** (`inc/*.php`, `views/admin/theme-options-page.php`) keep the boilerplate prefix, including every custom hook name. Every client project ships with Studio Val's placeholder prefix, and two client sites sharing a host collide on hook names.

**S1.4 — A non-interactive run aborts mid-migration, with no rollback.**

Three mandatory `read` calls have no non-interactive fallback: 732, 754, 762, 811. Under `set -e`, `read` at EOF returns non-zero and kills the script. The plugin prompt (811) fires **after** the theme has already been `mv`'d (785), `style.css` rewritten, ~100 files sed'd and both deploy workflows patched. Piping the script, running it from CI, or running it under any non-TTY leaves a half-migrated tree. There is no `trap` beyond `stop_spinner` and no rollback.

**S1.5 — The "pristine base" guard has a hole in exactly the re-run case.**

The guard (696–699) tests `wp-content/themes/theme-fse/style.css`. After a successful run that file no longer exists, so `[ -f … ]` is false and the guard **passes**. Re-running the script therefore proceeds: it re-detects themes, re-prompts, potentially renames again, re-substitutes, re-installs plugins and `git add -A && git commit` a second time. The guard catches the `demo` branch and nothing else. **The script is not idempotent and the one mechanism meant to protect it does not fire.**

### S2 — High: silent failures and unreachable error handling

**S2.1 — `set -e` makes three error branches dead code.**

- `active_theme=$($WP theme list … 2>/dev/null)` (912) — no `||` guard. If `wp theme list` fails, the script dies; the warning at 917–920 is unreachable.
- `homepage_id=$($WP post create … --porcelain 2>/dev/null)` (977) — same. The "Could not create homepage" branch (1002–1005) can never run.
- `git commit` (557) — unguarded. On a machine without `user.email`/`user.name`, the script aborts at the very last step, after every mutation has landed.

**S2.2 — `increment_errors` is never called; the summary always reports 0 errors.**

`increment_errors` (132) and `log_error` (90) have **zero call sites**. `show_setup_summary` therefore always takes the `SETUP_ERRORS -eq 0` path and prints "🎉 Perfect setup! No issues encountered." or "minor warnings" — regardless of what actually happened. The summary is decorative.

**S2.3 — `--theme=` is trusted without existence check.**

With `--theme=X` (710–711) `SLUGS` is set to `X` without verifying the directory exists. At 779 the `[ -d "$THEME_SOURCE" ]` test fails → a *warning*, not an error → the run continues with `THEME_DEST` set → line 899 then tries to activate a theme that was never created. Degraded to a warning at 923.

**S2.4 — Substitutions hardcode `theme-fse` as the source, silently no-op otherwise.**

`update_workflow_files` (513, 525) seds `wp-content/themes/theme-fse/` regardless of the actual `THEME_SRC`. With `--theme=` pointing anywhere else, the workflows are left untouched and the script still reports success.

**S2.5 — The deploy-guard deletion is a range `sed` that can run away.**

`sed_inplace "/# The boilerplate repo is a template/,/if: github.repository != /d"` (515, 527). If the opening comment is ever reworded, it deletes nothing (silent). If the comment matches but the `if:` line drifts, **it deletes to end of file**. Destructive range delete on a CI file with no verification afterwards.

**S2.6 — 13 plugins installed from the network with failures downgraded to warnings.**

837–892: every `wp plugin install` failure becomes `log_warning "may already exist or network issue"`. A fully offline run "succeeds" with 13 warnings and a green summary. The plugin list is hardcoded in the script with no opt-in/opt-out per plugin, and `--skip-plugins` is all-or-nothing.

**S2.7 — Destructive operations with no confirmation and no dry-run parity.**

No summary-and-confirm step before: `mv` of the theme folder (785), `mv` of the plugin folder (479–480), ~100 in-place `sed`s, `wp post delete --force` on "Sample Page" (998), `wp theme activate`, DB writes via `wp option update`, and `git add -A` + commit (553–557) which stages **everything untracked in the tree**. `--dry-run` exists but skips whole blocks (829, 899, 931) rather than printing what they would do — so the dry run does not describe the real run.

### S3 — Medium: hygiene, portability, maintainability

**S3.1 — Not bash strict mode.** `set -e` only (7). No `-u`, no `-o pipefail`. Unset-variable typos fail silently; pipeline failures are swallowed.

**S3.2 — Undeclared dependency on `python3`** (1022) to parse `ddev describe -j`, in a PHP project, with a silent `|| echo` fallback to a guessed URL.

**S3.3 — DDEV status detected by grepping JSON.** `ddev describe -j 2>/dev/null | grep -q '"status":"running"'` (637) matches *any* service's status field, not the project's.

**S3.4 — `LOG_DELAY=0.05` before every log line.** Dozens of `sleep 0.05` calls plus the spinner's `sleep 0.08` loop — pure artificial latency. Also a portability hazard: fractional `sleep` is not POSIX.

**S3.5 — No prerequisite validation.** The script checks WP-CLI, `wp-config.php` and `wp-includes/version.php`, and nothing else. Missing: `composer`, `npm`, Node version against `.nvmrc`, PHP ≥ 8.2, `git` + a configured identity, `ddev` running. The `msgfmt` check (237) is the only well-guarded optional dependency.

**S3.6 — Theme auto-detect will usually find multiple themes.** `find … -maxdepth 1 -type d` (715) lists every theme folder including the `twenty*` bundles that `wp core install` brings in — so the "single theme" happy path (744) rarely holds on a real install, and the user is pushed into the interactive prompt at 754.

**S3.7 — Asymmetric `find` exclusions.** The theme walk (209–210) excludes `node_modules`, `dist`, `vendor`. The plugin walk (381–386) excludes `node_modules` and `dist` but **not `vendor`**. If anyone ever runs `composer install` inside the plugin, its vendored PHP gets identifier-substituted.

**S3.8 — `PLUGIN_INITIALS` produces a one-letter CSS prefix for single-word slugs.** `plugin_compute_forms` (340) maps `acme → a`, so `svpb-` becomes `a-` — a CSS class prefix generic enough to collide with anything.

**S3.9 — Agency identity hardcoded into client output.** `Theme URI: https://github.com/valentin-grenier/$theme_slug` (291) and `Plugin Name: Studio Val • …` (391) are baked in with no flag. `docs/setup.md` documents a `--github-user=USER` flag that does not exist.

**S3.10 — DDEV project name is never updated.** `.ddev/config.yaml` stays `name: wp-boilerplate-fse`, so every client project answers on `wp-boilerplate-fse.ddev.site` and `bin/smoke.sh` curls that URL.

**S3.11 — `--help` and `docs/setup.md` disagree with the code.** `docs/setup.md` documents `--skip-git` and `--github-user=USER` (neither exists) and omits `--skip-plugin-boilerplate` and `--plugin-dest`. Unknown flags are silently ignored (627), so `./bin/setup.sh --skip-git` runs a full setup while the user believes git was skipped.

**S3.12 — Branches created before deploy secrets exist.** `finalize_project_branches` creates `staging` while `update_workflow_files` has just removed the template deploy guard. The first push to `staging` triggers an FTP deploy against unconfigured secrets. The script never pushes or sets upstream either, so the branches are local-only.

### S4 — Low

- **S4.1** Spinner writes `\r…` to stdout concurrently with `log_*` output; interleaving garbles the terminal on slow installs.
- **S4.2** `error_exit` always suggests `--dry-run`, even for failures a dry run cannot diagnose (missing WP core, missing WP-CLI).
- **S4.3** Mixed French and English in user-facing strings (644, 670, 683 in French; the rest in English) — `.claude/CLAUDE.md` mandates English for code and docs.
- **S4.4** `logs/setup-<timestamp>.log` is written but never surfaced on failure and never cleaned up.
- **S4.5** Seeded homepage content is hardcoded French markup inside the script (943–973).

---

## 3. The four named issues — verdict

### 3.1 "PSR-4 autoload path breaks after the theme folder is renamed" — **premise incorrect, real defect elsewhere**

There is no `autoload` block in `composer.json` and no PSR-4 mapping anywhere in the repo (`grep -rn autoload composer.json` → only `optimize-autoloader: true`). No autoload path can break.

The defect that matches the symptom is **S1.1**: `phpcs.xml.dist`, `phpstan.neon.dist`, `phpunit.xml.dist`, `ci.yml` and `dependabot.yml` all hardcode `wp-content/themes/theme-fse/` and none of them is rewritten on theme rename. The tooling breaks after the rename — just via config paths, not the autoloader. **Real, S1.**

### 3.2 "Hardcoded `StudioVal\Boilerplate\` namespace" — **premise incorrect**

No PHP namespace declarations exist in the codebase (`grep -rn "^namespace" wp-content/` → zero). The theme is procedural by convention; the plugin uses a class-name prefix (`Studioval_Plugin_Boilerplate_`), not a namespace — and the plugin's prefix **is** correctly substituted (348–354).

`docs/setup.md` still tells the reader the setup script substitutes `StudioVal\Boilerplate\`. That line is stale documentation and should be deleted. The genuine unsubstituted identifier is **`sv_boilerplate_`** — see **S1.3**, which is the S1-severity version of this concern.

### 3.3 "Ambiguous ordering between `composer install` and `setup.sh`" — **confirmed**

The script **never runs `composer install`**, never checks that `vendor/` exists, and never mentions Composer in its "Next steps" (1021–1026) — it only mentions `npm`. `docs/setup.md` puts `composer install` at step 5, *after* setup.sh and after npm, with no stated reason.

Consequences:
- The script rewrites `phpstan.neon.dist` and `phpcs.xml.dist` but cannot validate its own output, because the tools may not be installed yet.
- A user who runs `composer install` first hits the vendor-exclusion asymmetry in **S3.7**.
- Neither order is wrong today, but nothing states or enforces one, and the script's own final message contradicts the docs.

### 3.4 "`auth.json.example` vs `auth.example.json` filename mismatch" — **confirmed, but it's a dangling reference**

Neither file exists. `.env.example:12-14` still says:

```
# ACF Pro
# The setup script prefers auth.json (see auth.json.example). This is a fallback.
ACF_PRO_LICENSE=
```

`bin/setup.sh` contains no `auth` handling at all, and `CHANGELOG.md:50` records that the ACF Pro dependency was removed when blocks went native. So this is **dead documentation for a removed feature**, pointing at a file that was deleted. The whole ACF block should come out of `.env.example`.

---

## 4. Proposed target structure

### 4.1 Move out of the script entirely

| Current | Belongs in | Why |
|---------|-----------|-----|
| Plugin installation (828–896) | `.ddev/config.yaml` `hooks.post-start`, or a `ddev` custom command | DDEV already owns environment provisioning and re-runs hooks idempotently. 13 network installs do not belong in a rename script. |
| Homepage + front-page + Sample Page (930–1007) | `bin/seed-content.sh`, or `ddev wp` snippets in `docs/setup.md` | Content seeding is orthogonal to project scaffolding, and re-running it is destructive. |
| Theme activation (898–928) | Final step of the seed script, or documented one-liner | `docs/setup.md` already documents the manual command. |
| `npm install` / `npm run build` guidance (1023–1025) | `ddev` post-start hook or `composer` script | Currently printed as advice the user must remember. |
| `composer install` | Explicit prerequisite step, checked by the script | See §3.3 — the order must be stated and verified. |
| Branch creation + first commit (536–571) | `bin/init-project-git.sh`, invoked explicitly | Committing and branching is a separate decision from renaming, and the current `git add -A` is too broad. |
| Logging/spinner/counters (28–174) | `bin/lib/log.sh` | ~150 lines of presentation code ahead of any logic; reusable by `smoke.sh`, `reset-theme-json.sh`, `setup-branch-protection.sh`. |

### 4.2 Remove outright

- `LOG_DELAY` and every `sleep` in the log path (S3.4).
- The spinner (S4.1) — or move it to `lib/log.sh` and make it opt-in.
- `increment_errors` / `log_error` dead code, **or** actually wire them up (S2.2).
- The `python3` URL derivation (S3.2) — use `ddev describe -j | jq` or just print the documented pattern.
- The ACF Pro block in `.env.example` (§3.4).
- Stale `StudioVal\Boilerplate\`, `--skip-git` and `--github-user` references in `docs/setup.md` (§3.2, S3.11).

### 4.3 Target layout

```
bin/
├── setup.sh              # thin orchestrator: flags → preflight → plan → confirm → steps → report
└── lib/
    ├── log.sh            # colours, log_*, counters — no sleeps, errors actually counted
    ├── preflight.sh      # ddev, wp-cli, composer, npm+.nvmrc, php>=8.2, git identity, vendor/
    ├── slug.sh           # validation + all identifier derivations (theme + plugin)
    ├── rename-theme.sh   # mv + style.css + text-domain + sv_boilerplate_ prefix
    ├── rename-plugin.sh  # existing plugin logic, plus vendor/ exclusion
    ├── rewrite-configs.sh # ONE place that owns every theme-fse/studioval-* path:
    │                      # phpcs, phpstan, phpunit, ci.yml, dependabot.yml,
    │                      # deploy-*.yml, .gitignore, .ddev/config.yaml, bin/smoke.sh
    └── verify.sh         # post-run: paths resolve, no placeholder left, composer ci green
```

**Single source of truth for paths.** One `PLACEHOLDER_FILES` manifest listing every file containing `theme-fse` / `studioval-boilerplate` / `studioval-plugin-boilerplate` / `sv_boilerplate_`, driving both the rewrite and a final `verify.sh` grep that fails the run if any placeholder survives outside `CHANGELOG.md` and `docs/`. **This is the single highest-value change**: S1.1, S1.2, S1.3 and S2.4 are all the same bug — an incomplete, duplicated list of paths.

**Execution shape:**
1. Parse flags — **reject unknown flags** instead of ignoring them (S3.11).
2. Preflight: every prerequisite, before any mutation. Fail with a "run this next" message.
3. Resolve every input (slugs, from flags or prompts **with documented `--yes` non-interactive defaults**) — all prompting finishes before the first `mv`, which kills S1.4.
4. Print the full plan (files touched, folders renamed, commands run). `--dry-run` stops here; a real run confirms unless `--yes`.
5. Execute, each step idempotent and individually re-runnable.
6. `verify.sh`, then a summary whose error count is real.

**Idempotency:** replace the `style.css` guard (S1.5) with a `.setup-state` marker (or a positive check that placeholders still exist across the whole manifest), and make every step a no-op when its target state already holds.

### 4.4 Flag surface

Keep `--dry-run`, `--theme-dest`, `--plugin-dest`, `--skip-branches`. Add `--yes` (non-interactive, all defaults), `--github-user` (S3.9, already documented but missing), `--ddev-name`. Drop `--theme=` or make it validate the directory exists (S2.3). Re-sync `--help` and `docs/setup.md` from one source.

---

## 5. Duplicated by DDEV / Composer / npm

| In the script | Native equivalent |
|---------------|-------------------|
| `wp plugin install` ×13 (828–896) | `.ddev/config.yaml` `hooks.post-start` — DDEV re-runs them on every start, idempotently |
| WP-CLI presence detection (635–645) | `ddev wp` always exists inside the container; the three-way `cmd //c wp` / `ddev wp` / `wp` branch is DDEV's job |
| `wp core is-installed` check (677–688) | `ddev wp core install` in a post-start hook, or the documented step already in `docs/setup.md` |
| `wp-config.php` / `wp-includes/version.php` checks (655–674) | `ddev start` already fails loudly on a broken WordPress root |
| Theme URL derivation via `python3` (1022) | `ddev describe` / `ddev launch` |
| `npm install && npm run build` printed as advice (1023–1025) | a `postinstall` / `setup` npm script, or a DDEV post-start hook |
| `msgfmt` .po → .mo compilation (237–243) | `ddev wp i18n make-mo`, already in the WP-CLI the script depends on |
| Logging framework (28–174) | Not duplicated, but ~150 lines of bespoke presentation for a ~400-line job |
| Timestamped log file (45–61) | `./bin/setup.sh 2>&1 \| tee` |

**Not duplicated and genuinely this script's job:** slug validation, identifier derivation, folder renames, placeholder substitution, and config-path rewriting. That is the ~200-line core worth keeping; the other ~800 lines are either delegable or removable.

---

## Recommended order for Phase 2

1. **S1.1 + S1.2 + S1.3 + S2.4** — the path/placeholder manifest. One change, four critical bugs.
2. **S1.4 + S1.5** — prompt-before-mutate, `--yes`, real idempotency guard.
3. **S2.1 + S2.2 + S3.1** — strict mode, guard every `$(…)`, wire up the error counter.
4. **S2.5 + S2.7** — replace the range `sed`, add plan-and-confirm, make `--dry-run` cover every block.
5. **S3.5** — the preflight module.
6. Extraction into `bin/lib/*` and the moves out to DDEV/npm (§4.1).
7. Docs + `.env.example` cleanup (§3.2, §3.4, S3.11).
