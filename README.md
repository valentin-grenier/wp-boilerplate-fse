# FSE Boilerplate WordPress Theme

A modern, clean, and production-ready starter theme for building custom WordPress Full Site Editing (FSE) themes — powered by Sass and modular PHP.

## 🧩 Features

-   **Full FSE support**: Templates and template parts structured in native `.html` files
-   **Custom styles via `theme.json`**: Define your color palette, spacing, typography, and block settings
-   **SCSS workflow included**: Compiles separate frontend and editor styles using `npm run build` or `npm run watch`
-   **Modular PHP architecture**: Split into logical `inc/` files (`theme-setup`, `assets`, `security`, `performance`, etc.)
-   **Block restrictions**: Disable unused block styles, comment-related blocks, and dashboard widgets
-   **Console signature**: A developer-friendly signature logs in the browser console on every load
-   **Security hardening**: XML-RPC disabled, file editor blocked, version info hidden, and more
-   **Editor experience optimized**: Clean block inserter with only relevant styles and blocks
-   **Automated setup**: Complete WordPress installation with theme activation, plugin installation, and Git workflow

## 🚀 Quick Start

### Option 1: With ACF Pro License

```bash
# Set up with ACF Pro license key
./bin/setup.sh --acf-license=YOUR_LICENSE_KEY

# Or use environment variable
export ACF_PRO_LICENSE="your_license_key"
./bin/setup.sh

# Or add to auth.json (copy from auth.example.json)
./bin/setup.sh
```

### Option 2: Without ACF Pro

```bash
# Basic setup without ACF Pro
./bin/setup.sh

# Development workflow
cd wp-content/themes/your-theme-name/_dev
npm install
npm run watch       # Watch SCSS for changes
```

### Setup Options

-   **Theme folder name**: The setup script defaults the theme folder to `wp-boilerplate-fse` to align with the GitHub Actions deployment workflow
-   **Customization**: You can override the theme name using `--theme-dest=your-custom-name` if needed
-   **Directory structure**: The script moves all boilerplate content to your WordPress root directory
-   **Git workflow**: Automatically creates development branches (`staging`, `development`, `feature/initial-setup`) for a complete Git workflow
-   **Deployment sync**: Automatically updates GitHub workflow files with the chosen theme name for seamless deployment

## 🌿 Git Workflow

The setup script creates a complete branching strategy:

-   **`main`** - Production-ready code (protected branch)
-   **`staging`** - Pre-production testing and QA
-   **`development`** - Active development and integration
-   **`feature/initial-setup`** - Example feature branch template

**Deployment flow:**

```text
feature/xxx → development → staging → main
```

**Skip branch creation:** Use `--skip-branches` if you prefer a simpler Git setup.

## ⚙️ Setup Script Options

```bash
./bin/setup.sh [OPTIONS]

Options:
  --dry-run             Show what would be done without making changes
  --skip-plugins        Skip automatic plugin installation
  --skip-git            Skip git repository initialization
  --skip-branches       Skip creating additional git branches (staging, development)
  --theme=NAME          Override source theme name detection
  --theme-dest=NAME     Override destination theme name
  --github-user=USER    Override GitHub username (default: valentin-grenier)
  --acf-license=KEY     ACF Pro license key for installation
  --help, -h            Show this help message
```

## 🔑 ACF Pro Configuration

To automatically install ACF Pro during setup, provide your license key using one of these methods:

1. **Command line flag**: `--acf-license=YOUR_KEY`
2. **Environment variable**: `export ACF_PRO_LICENSE="YOUR_KEY"`
3. **auth.json file**: Copy `auth.example.json` to `auth.json` and add your license key as the password

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

## 🚀 GitHub Actions Deployment

### Required Secrets

To enable deployment via GitHub Actions, add the following secrets to your repository:

**For staging deployment (FTP):**

-   `STAGING_FTP_HOST` – your FTP server hostname (e.g., ftp.example.com)
-   `STAGING_FTP_PORT` – FTP port (usually 21)
-   `STAGING_FTP_USER` – FTP username
-   `STAGING_FTP_PASSWORD` – FTP password
-   `STAGING_FTP_SERVER_DIR` – WordPress installation root directory

**For production deployment (if different from staging):**

-   `FTP_HOST` – production FTP server hostname
-   `FTP_PORT` – production FTP port
-   `FTP_PROTOCOL` – protocol ("ftp" or "ftps")
-   `FTP_USER` – production FTP username
-   `FTP_PASSWORD` – production FTP password
-   `FTP_SERVER_DIR` – production WordPress installation root directory

### Deployment Triggers

-   **Staging**: Deploys automatically when code is pushed to `staging` branch
-   **Production**: Deploys automatically when code is pushed to `main` branch

## 🛠️ Development

### Build Scripts

```bash
# Development build with watch mode
npm run dev

# Production build (minified, optimized)
npm run build

# Watch mode for development (if available)
npm run watch
```

### File Structure

```
wp-content/themes/your-theme/
├── _dev/                    # Development assets
│   ├── js/                  # JavaScript source files
│   ├── scss/                # SCSS source files
│   ├── blocks/              # Custom block development
│   ├── package.json         # Node.js dependencies
│   └── webpack.*.js         # Webpack configuration
├── assets/                  # Compiled assets
│   ├── css/                 # Compiled CSS
│   └── js/                  # Compiled JavaScript
├── inc/                     # PHP includes
│   ├── theme-setup.php      # Theme configuration
│   ├── security.php         # Security enhancements
│   ├── performance-hooks.php # Performance optimizations
│   └── ...                  # Other modular functionality
├── parts/                   # Template parts
├── templates/               # Full site editing templates
├── functions.php            # Main theme functions
├── style.css               # Theme header and basic styles
└── theme.json              # FSE configuration
```

## 🔌 Recommended Plugins

### Development Plugins (Auto-installed)

-   **Query Monitor** – Development debugging
-   **UpdraftPlus** – Backup and migration
-   **Admin Site Enhancements** – Admin experience improvements
-   **Contact Form 7** – Form builder

### Production Plugins (Manual installation)

-   **Broken Link Checker** – SEO maintenance
-   **Rank Math SEO** – SEO optimization
-   **Better WP Security** – Security enhancements
-   **Complianz GDPR** – Privacy compliance
-   **WebP Converter for Media** – Image optimization
-   **Simple History** – Activity logging
-   **Plausible Analytics** – Privacy-friendly analytics

## ✍️ Author

Made with ❤️ by **Studio Val** — a creative WordPress developer focused on fast, modern, maintainable custom themes.

-   Website: [studio-val.fr](https://studio-val.fr)
-   GitHub: [@valentin-grenier](https://github.com/valentin-grenier)

## 📄 License

MIT — free to use and adapt with attribution.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
