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
  --help, -h            Show this help message
```

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

## MCP — drive WordPress from Claude Code (optional)

The repo ships an `.mcp.json` that registers a `wordpress` MCP server. Claude Code reads it automatically, letting Claude query and manage the local WordPress over the [Model Context Protocol](https://modelcontextprotocol.io/) through DDEV's WP-CLI (STDIO transport — no secrets stored).

**Requirements:** `ddev start` running, WordPress installed (`bin/setup.sh`), WordPress ≥ 6.9, and an admin user (the login chosen at setup — `admin` by convention).

1. Install the [MCP Adapter](https://github.com/WordPress/mcp-adapter) into the local site (GitHub release — not on wp.org):

   ```bash
   ddev wp plugin install https://github.com/WordPress/mcp-adapter/releases/latest/download/mcp-adapter.zip --activate
   ddev wp mcp-adapter list   # should list "mcp-adapter-default-server"
   ```

   If the zip install fails, clone the repo into `wp-content/plugins/mcp-adapter/`, run `ddev composer install` inside that folder, then `ddev wp plugin activate mcp-adapter`.

2. (Re)start Claude Code in the project root, then check the connection:

   ```bash
   claude mcp list   # "wordpress" should report: connected
   ```

   If your admin login is not `admin`, export `WP_MCP_USER=<login>` before launching Claude Code — the `.mcp.json` reads `${WP_MCP_USER:-admin}` from the shell environment, not from `.env`.

> **Note:** DDEV must be running before you start Claude Code, otherwise a container start-up message can corrupt the STDIO JSON-RPC stream. Fallback command: `ddev exec -s web wp mcp-adapter serve --server=mcp-adapter-default-server --user=admin`.

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
