# CLAUDE.md — WP FSE Boilerplate

Session-start context for Claude Code on this repository.

## What this is

Studio Val boilerplate for starting a WordPress **Full Site Editing** (FSE) theme turn-key. The
repo contains **only the theme + DDEV config + tooling** — the WordPress core (`wp-admin/`,
`wp-includes/`, `wp-config.php`, etc.) is present locally to run the site but is **not versioned**
(see `.gitignore`).

The theme lives at [wp-content/themes/theme-fse/](../wp-content/themes/theme-fse/).

## Stack

- **WordPress** 6.0+, **PHP** 8.2+.
- **Webpack 5** custom + **Sass** — **not** `wp-scripts`. Migration possibly planned later:
  **do not propose a refactor to wp-scripts without explicit approval.**
- **DDEV** (config versioned in `.ddev/`).
- **ACF Pro** for custom blocks (credentials via `auth.json`, gitignored).
- **Composer**: WPCS (WordPress-Extra ruleset via `phpcs.xml.dist`) + `phpstan` level 5 with
  `szepeviktor/phpstan-wordpress` (via `phpstan.neon.dist`) + PHPCompatibility (WP 8.2 target).

## Key tree layout

```text
.
├── wp-content/themes/theme-fse/
│   ├── style.css                  # Theme header (Theme Name, Version, Text Domain)
│   ├── theme.json                 # Global FSE config (palette, typography, layout)
│   ├── functions.php              # require-only: glob(inc/*.php)
│   ├── inc/                       # PHP logic split by concern (auto-loaded by functions.php)
│   ├── templates/                 # FSE templates (.html) — index, home, single, page, 404…
│   ├── parts/                     # header.html, footer.html
│   ├── styles/                    # Style variations (JSON)
│   ├── _dev/                      # Source: SCSS, JS, blocks, webpack — edit here, not in dist/
│   └── dist/                      # Build output (committed — see .gitignore)
├── .claude/                          # Claude Code config + team docs
│   ├── CLAUDE.md                     # This file
│   ├── ARCHITECTURE.md               # Repo map + responsibilities
│   ├── BLOCKS.md                     # ACF block authoring
│   ├── CONVENTIONS.md                # Prefixes, security, i18n, git
│   └── settings.json                 # Permissions allow/deny
├── .ddev/                            # DDEV config (versioned — in git)
├── bin/
│   └── setup.sh                      # Full install: renames the theme, substitutes placeholders, activates
├── .github/
│   ├── workflows/                    # deploy-staging.yml + deploy-production.yml (FTP)
│   └── CODEOWNERS
└── composer.json / auth.json.example / README.md / CHANGELOG.md / LICENSE / .editorconfig / .nvmrc / .env.example
```

## Essential commands

```bash
# Environment
ddev start                         # Start the local site
ddev ssh                           # Shell into the web container
ddev wp <cmd>                      # WP-CLI inside the container (e.g., ddev wp plugin list)

# Backend PHP
composer install                   # Installs WPCS + phpstan + phpunit + dealerdirect installer
composer lint                      # phpcs (reads phpcs.xml.dist — WordPress-Extra)
composer lint:fix                  # phpcbf
composer stan                      # phpstan analyse (level 5, WP bootstrap)
composer test                      # phpunit
composer ci                        # lint + stan + test

# Frontend (from _dev/)
cd wp-content/themes/theme-fse/_dev
npm install
npm run dev                        # Webpack dev mode + BrowserSync
npm run build                      # Production build (minified)
npm run make-block                 # Scaffold a new block (interactive prompts)
```

## Code conventions

- **Language**: code, comments, **and all documentation** in English.
- **Text-domain**: `studioval-boilerplate` (declared in
  [`style.css`](../wp-content/themes/theme-fse/style.css)). `bin/setup.sh` substitutes the
  `boilerplate` token with the client project slug on install. Normalized consistently across the
  theme.
- **Hook / function prefix**: `sv_boilerplate_` (e.g., `sv_boilerplate_register_blocks`,
  `sv_boilerplate_enqueue_assets`) — `bin/setup.sh` substitutes the `boilerplate` token with the
  client project slug on install.
- **PHP style**: procedural throughout — no namespaces. All functions use the `sv_boilerplate_`
  prefix. Do not introduce classes or `namespace` declarations without explicit approval.
- **Block namespace**: `studioval/{slug}` in `block.json` (already applied to the block template).
- **WP security**: every `inc/*.php` starts with `if ( ! defined( 'ABSPATH' ) ) { exit; }` — guard
  applied to all 14 files. All output must be escaped (`esc_html`, `esc_attr`, `esc_url`,
  `wp_kses_post`), all input sanitized (`sanitize_text_field`, `absint`, etc.), all SQL queries via
  `$wpdb->prepare`, all action/admin-post handlers protected by nonce.
- **i18n**: systematic (`__()`, `esc_html__()`, `_e()`, `_x()`…).
- **Blocks**: one folder per block in `_dev/blocks/{name}/`. Each `block.json` is auto-discovered
  by [inc/block-acf.php](../wp-content/themes/theme-fse/inc/block-acf.php), which globs recursively.
- **Asset cache-busting**: `filemtime()` on the compiled file — **do not** hardcode a version.
- **`_dev/blocks/block/block.js` is intentionally empty**: it is the skeleton consumed by
  `scripts/make-block.js` when scaffolding a new block.
- **Git**: Semantic Commits in the format `type: Scope - Subject` (preterit) — e.g.,
  `feat: Single - Added breadcrumb block`. Types and full rules in
  [`CONVENTIONS.md`](CONVENTIONS.md#git).

## Files / folders never to modify

- [wp-config.php](../wp-config.php), [wp-config-ddev.php](../wp-config-ddev.php),
  [wp-config-sample.php](../wp-config-sample.php) — sensitive config (DB, salts).
- `auth.json` (gitignored) — ACF Pro credentials.
- `wp-content/themes/theme-fse/dist/**` — **modify only indirectly** via `npm run build`.

## Tests

PHPUnit is pre-wired via [`phpunit.xml.dist`](../phpunit.xml.dist). No test files exist yet —
`composer test` exits 0 today because `failOnEmptyTestSuite="false"` is set. Add `*Test.php` files
under `tests/` to start building coverage. Run with `composer test` or as part of `composer ci`.

## Git workflow

Main branches (created automatically by `bin/setup.sh`):

- `main` — production, protected.
- `staging` — pre-prod, triggers `deploy-staging.yml` on push.
- `development` — continuous integration.
- `feature/*` — development.

Automatic deployment via GitHub Actions (FTP) on push to `staging` / `main`. `ci.yml` gates PHP
lint/stan/test + Node lint/build on every PR.

## Claude Code workflow

`gh` CLI is installed and authenticated via SSH. When asked to commit, push, and open a PR, do all
three without asking for confirmation. Use `gh pr create` with the body written in English, following
`.github/PULL_REQUEST_TEMPLATE.md`.

**Guardrails** — never run without explicit user instruction:

- `git push --force` / `git push --force-with-lease`
- `git reset --hard`
- `git rebase -i` or any other history rewrite on a shared branch
- `git branch -D` (delete branch)

## Known pitfalls

- **Theme not directly activatable**: the source theme uses default names (`sv_boilerplate_`,
  `studioval-boilerplate`, `StudioVal\Boilerplate\`). `bin/setup.sh` substitutes the `boilerplate`
  token with the client project slug on install. **Do not** activate `theme-fse` directly on a
  project without first running setup.
- **`_dev/blocks/block/block.js` is intentionally empty**: it's the skeleton consumed by
  `scripts/make-block.js` when scaffolding a new block.
- **Lint/stan green**: `composer ci` runs `phpcs lint` + `phpstan` at level 5 + `phpunit` and
  reports 0 errors. ~18 phpcs warnings remain (non-blocking) — `file_get_contents` /
  `file_put_contents` / `wp_redirect` alternative-fn suggestions, unused-param notes on hook
  callbacks with required WP signatures, and commented-out code in `dashboard.php`. Raise one
  phpstan level at a time as new code is added.
