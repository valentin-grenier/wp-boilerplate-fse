# Copilot Instructions for WordPress Boilerplate FSE

## Project Overview
Modern WordPress FSE boilerplate with automated setup (`bin/setup.sh`), modular PHP architecture, Webpack build pipeline, and FTP deployment via GitHub Actions. Designed for custom client sites by Studio Val.

**Tech Stack:** WordPress 6.0+, PHP 8.0+, Webpack 5, Sass, Local by Flywheel

## Architecture & Key Patterns

### Modular PHP Structure
- **`functions.php`** does ONE thing: auto-loads all files from `inc/` using `glob()`
- Each `inc/*.php` file handles a single concern (theme setup, security, assets, blocks, etc.)
- All functions prefixed with `studio_` to avoid conflicts
- Security guard at top of every file: `if (!defined('ABSPATH')) exit;`

**Example from `inc/theme-assets.php`:**
```php
// Cache-busted assets using filemtime()
wp_enqueue_style('studio-theme-styles', 
    get_template_directory_uri() . '/dist/css/theme.css',
    [], filemtime(get_template_directory() . '/dist/css/theme.css')
);
```

### Webpack Build Pipeline
- **Source:** `wp-content/themes/theme-fse/_dev/` (SCSS, JS, blocks)
- **Output:** `wp-content/themes/theme-fse/dist/` (compiled CSS/JS)
- **Auto-discovers blocks:** Webpack scans `_dev/blocks/*/` and bundles each `block.js` + `block.scss`
- **Commands:** `npm run dev` (dev build) or `npm run build` (production)
- Blocks output to `dist/blocks/{blockName}/block.{js,css}`

### ACF Block Registration
Blocks live in `_dev/blocks/{blockName}/` with this structure:
```
block.json    # Block metadata (title, category, supports)
block.php     # PHP template
block.scss    # Block styles
block.js      # Block editor scripts
```
Registration happens automatically via `inc/block-acf.php` which globs all `block.json` files:
```php
register_block_type($block_json_file); // For each found block.json
```

### FSE Configuration (`theme.json`)
- **All design tokens** (colors, spacing, typography) defined here
- Disables most WordPress defaults for regular users (`defaultPalette: false`, `defaultGradients: false`)
- `admin-caps.json` enables full editor capabilities (spacing, typography, borders) for administrators
- Custom palette with slugs: `primary`, `secondary`, `accent`, `contrast`, `white`
- Spacing scale: `xs` (1rem), `sm` (1.5rem), `md` (2rem), `lg` (4rem), `xl` (6rem)
- **Strict layout settings:** Fixed contentSize (760px) and wideSize (1140px)

**Variable Syntax (CRITICAL):**
- ✅ **USE:** `wp:preset|color|primary` or `wp:custom|spacing|small`
- ❌ **NEVER:** `var(--wp--preset--color--primary)` or `var(--wp--custom--spacing--small)`
- WordPress FSE uses colon-pipe notation, not CSS custom properties in theme.json

### Security Hardening (`inc/security.php`)
- XML-RPC disabled (`xmlrpc_enabled` filter)
- File editor blocked via `DISALLOW_FILE_EDIT` constant
- WordPress version hidden from source (`wp_generator` action removed)
- Login error messages sanitized to prevent user enumeration
- Author archives redirect to home (prevents user scanning)

## Development Workflows

### Initial Setup
```bash
./bin/setup.sh --acf-license=YOUR_KEY  # Full setup with ACF Pro
./bin/setup.sh --skip-plugins          # Skip plugin installation
./bin/setup.sh --dry-run               # Preview changes
```
**What it does:**
1. Detects/creates WordPress installation
2. Installs/activates theme
3. Installs plugins via WP-CLI
4. Creates Git branches (`staging`, `development`, `feature/initial-setup`)
5. Updates workflow files with theme name
6. Logs everything to timestamped `logs/setup-*.log`

### Asset Development
```bash
cd wp-content/themes/theme-fse/_dev
npm install
npm run dev      # Development build
npm run build    # Production build (minified)
```
**Watch for:** Webpack clears `dist/` on each build (configured with `clean: true`)

### Deployment Flow
```
feature/xxx → development → staging → main
```
- **Staging:** Push to `staging` branch → deploys via `.github/workflows/deploy-staging.yml`
- **Production:** Push to `main` → deploys via `.github/workflows/deploy-production.yml`
- Uses FTP-Deploy-Action with separate steps for root files, theme, and plugins
- Excludes: `node_modules/`, `vendor/`, `.git/`, development files

### Required GitHub Secrets
**Staging:** `STAGING_FTP_HOST`, `STAGING_FTP_PORT`, `STAGING_FTP_USER`, `STAGING_FTP_PASSWORD`, `STAGING_FTP_SERVER_DIR`  
**Production:** `FTP_HOST`, `FTP_PORT`, `FTP_PROTOCOL`, `FTP_USER`, `FTP_PASSWORD`, `FTP_SERVER_DIR`

## Code Style & Conventions

### PHP
- **Naming:** `snake_case` functions, `studio_` prefix mandatory
- **Security:** Escape ALL output (`esc_html()`, `esc_attr()`, `esc_url()`), sanitize ALL input
- **PHPDoc:** Every function documented with `@param`, `@return`
- **Performance:** Use `filemtime()` for cache busting, enable selective block CSS loading (`should_load_separate_core_block_assets`)

### SCSS
- **Modern syntax:** Use `@use` and `@forward`, NEVER `@import`
- **Organization:** Modular files in `scss/blocks/`, `scss/parts/`, `scss/templates/`, etc.
- **Mobile-first:** Base styles for mobile, use `@media` for larger screens

### JavaScript
- **ES6+:** Modern syntax, avoid jQuery
- **Block editor scripts:** Enqueue with dependencies like `['wp-blocks', 'wp-dom-ready']`
- Example pattern from `inc/block-settings.php`: Unregister blocks/styles via editor scripts

### Shell Scripts (`bin/*.sh`)
- **Cross-platform:** Test on macOS, Linux, Windows Git Bash
- **Error handling:** Always `set -e` at top
- **Logging:** Use `log_step()`, `log_success()`, `log_error()` with emojis
- **Dry-run support:** Check `$DRY_RUN` before executing
- **User feedback:** Progress indicators, summary at end with elapsed time

## Adding New Features

When adding new features:
- Always update `copilot-instructions.md` to reflect new patterns or workflows.
- Always update relevant documentation sections if needed.

### New PHP Module
1. Create `inc/new-feature.php`
2. Add security guard and PHPDoc
3. Prefix functions with `studio_`
4. Auto-loads via `functions.php` glob

### New ACF Block
1. Create folder: `_dev/blocks/my-block/`
2. Add files: `block.json`, `block.php`, `block.scss`, `block.js`
3. Webpack auto-discovers and compiles
4. Registration happens via `inc/block-acf.php`
5. New block can be created with `npm run make-block MyBlock` when in _dev directory

### Workflow Modification
1. Test in staging first
2. Never hardcode credentials (use secrets)
3. Update health check URLs if needed
4. Add deployment summary output

### Git commit messages pattern
- Use clear, descriptive and complete phrase with a maximum of two phrases.
- Always start a commit with the common prefix of the area being changed:
  - `chore`: for general maintenance tasks
  - `feat`: for new features
  - `fix`: for bug fixes
  - `docs`: for documentation changes
  - `style`: for code style changes (formatting, missing semi-colons, etc.)

## Critical "Don'ts"
- ❌ **Don't modify** `functions.php` (only for glob auto-loading)
- ❌ **Don't use** `@import` in SCSS (use `@use`/`@forward`)
- ❌ **Don't hardcode** theme name in workflows (setup script handles this)
- ❌ **Don't skip** security escaping/sanitization
- ❌ **Don't add** files directly to `dist/` (Webpack manages this)

## Key Files to Reference
- **Theme structure:** `wp-content/themes/theme-fse/`
- **Build config:** `_dev/webpack.common.js` (entry points, output paths)
- **Block patterns:** `_dev/blocks/block/` (example ACF block)
- **Setup automation:** `bin/setup.sh` (lines 1-100 show logging/error handling patterns)
- **Deployment:** `.github/workflows/deploy-staging.yml` (3-step FTP deploy)

## Questions to Ask Before Acting
- "Does this affect theme.json configuration?" (coordinate with design tokens)
- "Will this change require `npm run build`?" (any SCSS/JS modifications)
- "Should this be configurable via setup.sh flags?" (for reusability)
- "Does this need to work in both Local and production environments?"
