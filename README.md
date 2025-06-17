# FSE Boilerplate WordPress Theme

A modern, clean, and production-ready starter theme for building custom WordPress Full Site Editing (FSE) themes — powered by Sass and modular PHP.

## 🧩 Features

-   **Full FSE support**: Templates and template parts structured in native `.html` files.
-   **Custom styles via `theme.json`**: Define your color palette, spacing, typography, and block settings.
-   **SCSS workflow included**: Compiles separate frontend and editor styles using `npm run build` or `npm run watch`.
-   **Modular PHP architecture**: Split into logical `inc/` files (`theme-setup`, `assets`, `security`, `performance`, etc.).
-   **Block restrictions**: Disable unused block styles, comment-related blocks, and dashboard widgets.
-   **Console signature**: A developer-friendly signature logs in the browser console on every load.
-   **Security hardening**: XML-RPC disabled, file editor blocked, version info hidden, and more.
-   **Editor experience optimized**: Clean block inserter with only relevant styles and blocks.

## Required GitHub Actions Secrets

To enable deployment via GitHub Actions, add the following secrets to your new repo:

-   `STAGING_SFTP_HOST` – your SFTP server hostname (e.g., ftp.example.com)
-   `STAGING_SFTP_USER` – SFTP username
-   `STAGING_SFTP_PASS` – SFTP password
-   `STAGING_SFTP_DIR` – WordPress installation root directory

## 🚀 Quick Start

```bash
npm install
npm run watch       # Watch SCSS for changes
```

## Plugins

```bash
# Install plugins required for development
wp plugin install query-monitor --activate
wp plugin install updraftplus --activate
wp plugin install admin-site-enhancements --activate
wp plugin install contact-form-7 --activate

# Install plugins required for production
wp plugin install broken-link-checker
wp plugin install seo-by-rank-math
wp plugin install better-wp-security
wp plugin install complianz-gdpr
wp plugin install webp-converter-for-media
wp plugin install simple-history
wp plugin install plausible-analytics
```

## ✍️ Author

Made with ❤️ by Studio Val — a creative WordPress developer focused on fast, modern, maintainable custom themes.

## Licence

MIT — free to use and adapt with attribution.
