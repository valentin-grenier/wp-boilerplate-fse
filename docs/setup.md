# Setup guide

Step-by-step installation for the WP FSE Boilerplate.

## Prerequisites

- [DDEV](https://ddev.readthedocs.io/) installed and running
- Node.js — see `.nvmrc` for the required version (`nvm use` to activate it)
- Composer

## 1. Create your project from the template

Click **"Use this template" → Create a new repository** on the
[GitHub repo](https://github.com/valentin-grenier/wp-boilerplate-fse). The default branch
`main` is the pristine base (slug placeholders intact), so your new repo is ready for setup.
Then clone _your_ new repo into your WordPress root:

```bash
git clone https://github.com/<your-org>/<your-project>.git my-project
cd my-project
```

> The `demo` branch holds an installed example (placeholders already consumed); `bin/setup.sh`
> refuses to run from it. Always set up from the pristine `main`.

## 2. Start the local environment

```bash
ddev start
```

## 3. Run the setup script

The script renames the theme, substitutes all placeholder slugs with your project slug, installs plugins, commits the result on `main`, and creates the `staging` + `development` branches.

```bash
./bin/setup.sh
```

After the script completes, activate the theme in **wp-admin → Appearance → Themes** or via WP-CLI:

```bash
ddev wp theme activate your-project-slug
```

> **Note:** Do not activate `theme-fse` directly. The source theme uses generic placeholder
> names (`sv_boilerplate_` for PHP functions and hooks, `studioval-boilerplate` for the
> text domain). The setup script substitutes them with your project slug — always run it first.

## Script options

```
./bin/setup.sh [OPTIONS]

  --theme-dest=SLUG           Target theme folder name (required with --yes)
  --plugin-dest=SLUG          Target plugin slug, or 'skip' to leave it alone
  --theme-src=SLUG            Source theme folder (default: auto-detected)
  --theme-prefix=PREFIX       PHP function prefix (default: sv_<theme_dest>_)
  --github-user=USER          GitHub owner used in the Theme URI header

  --dry-run                   Print every action without performing any of them
  --yes, -y                   Non-interactive: take defaults, skip confirmation
  --force                     Run even when the placeholders look consumed

  --skip-plugins              Do not install the recommended wordpress.org plugins
  --skip-plugin-boilerplate   Leave the plugin scaffold untouched
  --skip-content              Do not create the homepage or activate the theme
  --skip-branches             Do not commit or create staging/development
  --help, -h                  Show this message
```

Unknown options are rejected rather than ignored, so a typo fails loudly instead of
silently running a full setup.

### Preview before committing to it

Every run prints a plan and asks for confirmation. To see the plan without touching
anything:

```bash
./bin/setup.sh --dry-run --theme-dest=my-project
```

### Non-interactive runs

The script never prompts without a fallback. With `--yes` it takes every default and
skips the confirmation, which makes it usable from CI or a provisioning script:

```bash
./bin/setup.sh --yes --theme-dest=my-project --plugin-dest=my-core
```

`--theme-dest` is required in that mode: there is no safe default for it.

### Re-running

Every step is idempotent, and the script refuses to run twice over a project that is
already set up. To deliberately rename an already-renamed project:

```bash
./bin/setup.sh --force --theme-src=my-project --theme-dest=my-new-name
```

## 4. Install dependencies

`bin/setup.sh` installs neither Composer nor npm dependencies — it only renames and
repoints. Do both afterwards, in either order; `composer ci` needs `vendor/` and the
theme build needs `node_modules/`.

```bash
# PHP
composer install

# Frontend
cd wp-content/themes/your-project-slug/_dev
nvm use
npm install
npm run dev    # Webpack watch + BrowserSync
```

## 5. Verify

```bash
composer ci      # lint + stan + test, pointing at your renamed theme
bin/smoke.sh     # end-to-end check
```

Both are repointed at the renamed theme by the setup script. If either still complains
about `theme-fse`, a config file was missed — report it, the path list lives in
`EXTERNAL_REFERENCE_FILES` at the top of `bin/setup.sh`.

## Daily development commands

```bash
# Environment
ddev start
ddev ssh
ddev wp <cmd>           # WP-CLI inside the container

# Frontend (from _dev/)
npm run dev             # Watch mode
npm run build           # Production build

# Backend
composer lint           # phpcs — WordPress-Extra ruleset
composer lint:fix       # phpcbf auto-fix
composer stan           # phpstan level 5
composer ci             # lint + stan + test in one pass
```

## GitHub Actions deployment

Staging and production deploys run via FTP on push to the `staging` and `main` branches.

### Required GitHub secrets

Go to **Settings → Environments**, create both `staging` and `production` environments, and add these secrets to each:

| Secret           | Description                                                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `FTP_HOST`       | FTP/SFTP hostname (e.g., `ftp.example.com`)                                                                                            |
| `FTP_PORT`       | `21` (FTP/FTPS) or `22` (SFTP)                                                                                                         |
| `FTP_PROTOCOL`   | `ftp`, `ftps`, or `sftp`                                                                                                               |
| `FTP_USER`       | FTP username                                                                                                                           |
| `FTP_PASSWORD`   | FTP password                                                                                                                           |
| `FTP_SERVER_DIR` | WordPress root with trailing slash (e.g., `/public_html/`) — the workflow appends `wp-content/themes/…` itself, do not include it here |

### Optional: restrict deployments by branch

In **Settings → Environments**:

- `production` — add required reviewers, restrict to the `main` branch.
- `staging` — restrict to the `staging` branch.

### Deployment triggers

| Branch    | Trigger                      |
| --------- | ---------------------------- |
| `staging` | Push → deploys to staging    |
| `main`    | Push → deploys to production |

## Git branching strategy

`main` comes from the template; `bin/setup.sh` commits the setup and adds `staging` + `development`:

```
feature/xxx → development → staging → main
```

| Branch        | Role                   |
| ------------- | ---------------------- |
| `main`        | Production, protected  |
| `staging`     | Pre-production QA      |
| `development` | Continuous integration |
| `feature/*`   | Active development     |

Never push directly to `main` or `staging`.

## Recommended plugins

**Installed _and activated_ by `setup.sh`:**

- Query Monitor — debug toolbar
- UpdraftPlus — backups
- Admin Site Enhancements — admin UX improvements
- Contact Form 7 + Honeypot — forms

**Installed but _not_ activated** (activate per project, when you need them):

- Broken Link Checker
- Rank Math SEO
- Complianz GDPR
- WebP Converter for Media
- Simple History
- Plausible Analytics
- WP Mail SMTP
- Better WP Security

Skip the whole step with `--skip-plugins`.
