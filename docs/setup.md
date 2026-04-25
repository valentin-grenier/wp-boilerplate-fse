# Setup guide

Step-by-step installation for the WP FSE Boilerplate.

## Prerequisites

- [DDEV](https://ddev.readthedocs.io/) installed and running
- Node.js — see `.nvmrc` for the required version (`nvm use` to activate it)
- Composer
- ACF Pro license (optional — the theme works without it, but custom block fields require it)

## 1. Clone into your WordPress root

```bash
git clone https://github.com/valentin-grenier/wp-boilerplate-fse.git my-project
cd my-project
```

## 2. Start the local environment

```bash
ddev start
```

## 3. Run the setup script

The script renames the theme, substitutes all `boilerplate` slug placeholders with your project slug, installs plugins, and creates Git branches.

```bash
# With ACF Pro
./bin/setup.sh --acf-license=YOUR_LICENSE_KEY

# Without ACF Pro
./bin/setup.sh
```

After the script completes, activate the theme in **wp-admin → Appearance → Themes** or via WP-CLI:

```bash
ddev wp theme activate your-project-slug
```

> **Note:** Do not activate `theme-fse` directly. The source theme uses generic placeholder names (`sv_boilerplate_`, `studioval-boilerplate`, `StudioVal\Boilerplate\`). The setup script substitutes them with your project slug — always run it first.

## Script options

```
./bin/setup.sh [OPTIONS]

  --dry-run             Show what would happen without making changes
  --skip-plugins        Skip automatic plugin installation
  --skip-git            Skip git repository initialization
  --skip-branches       Skip creating staging/development branches
  --theme=NAME          Override source theme name detection
  --theme-dest=NAME     Override destination theme folder name
  --github-user=USER    Override GitHub username (default: valentin-grenier)
  --acf-license=KEY     ACF Pro license key
  --help, -h            Show this help message
```

## ACF Pro configuration

Three ways to supply your license key — pick one:

**1. Command line flag:**
```bash
./bin/setup.sh --acf-license=YOUR_LICENSE_KEY
```

**2. Environment variable:**
```bash
export ACF_PRO_LICENSE="your_license_key"
./bin/setup.sh
```

**3. auth.json file:**
```bash
cp auth.example.json auth.json
```
Edit `auth.json` and set your key as the password:
```json
{
    "http-basic": {
        "connect.advancedcustomfields.com": {
            "username": "",
            "password": "YOUR_LICENSE_KEY_HERE"
        }
    }
}
```
`auth.json` is gitignored — never commit it.

## 4. Install frontend dependencies

```bash
cd wp-content/themes/your-project-slug/_dev
nvm use
npm install
npm run dev    # Webpack watch + BrowserSync
```

## 5. Install PHP dependencies

```bash
composer install
```

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

| Secret | Description |
|--------|-------------|
| `FTP_HOST` | FTP/SFTP hostname (e.g., `ftp.example.com`) |
| `FTP_PORT` | `21` (FTP/FTPS) or `22` (SFTP) |
| `FTP_PROTOCOL` | `ftp`, `ftps`, or `sftp` |
| `FTP_USER` | FTP username |
| `FTP_PASSWORD` | FTP password |
| `FTP_SERVER_DIR` | WordPress root with trailing slash (e.g., `/public_html/`) — the workflow appends `wp-content/themes/…` itself, do not include it here |

### Optional: restrict deployments by branch

In **Settings → Environments**:
- `production` — add required reviewers, restrict to the `main` branch.
- `staging` — restrict to the `staging` branch.

### Deployment triggers

| Branch | Trigger |
|--------|---------|
| `staging` | Push → deploys to staging |
| `main` | Push → deploys to production |

## Git branching strategy

The setup script creates these branches automatically:

```
feature/xxx → development → staging → main
```

| Branch | Role |
|--------|------|
| `main` | Production, protected |
| `staging` | Pre-production QA |
| `development` | Continuous integration |
| `feature/*` | Active development |

Never push directly to `main` or `staging`.

## Recommended plugins

**Auto-installed by `setup.sh`:**
- Query Monitor — debug toolbar
- UpdraftPlus — backups
- Admin Site Enhancements — admin UX improvements
- Contact Form 7 — forms

**Install manually on production projects:**
- Rank Math SEO
- Complianz GDPR
- WebP Converter for Media
- Simple History
- Plausible Analytics
