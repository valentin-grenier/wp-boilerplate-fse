# Copilot Instructions for WordPress Boilerplate FSE

## Project Overview
This is a modern WordPress Full Site Editing (FSE) theme boilerplate with automated setup, deployment workflows, and development tools.
Core Principles
Code Style

## PHP: Follow WordPress coding standards

- Use snake_case for functions
- Prefix all functions with studio_
- Comment every function with PHPDoc blocks
- Security first: escape, sanitize, validate

## JavaScript: ES6+ syntax

- Use modern imports/exports
- Avoid jQuery when possible
- Comment complex logic


## SCSS: Modern module syntax

- Use @use and @forward, never @import
- Keep files modular in organized directories
- Mobile-first approach


## Shell Scripts

- Compatibility: Must work on macOS, Linux, and Windows (Git Bash/WSL)
- Safety: Always use set -e to exit on errors
- User feedback: Log every important step with emojis for clarity
- Dry-run: Support --dry-run flag for testing
- Error handling: Clear error messages with helpful suggestions

## WordPress Best Practices

### Security

- Never trust user input
- Use nonces for forms
- Escape output: esc_html(), esc_attr(), esc_url()
- Sanitize input: sanitize_text_field(), etc.


### Performance

- Lazy-load assets when possible
- Only enqueue what's needed
- Use filemtime() for cache busting
- Leverage WordPress transients for caching

### FSE Specifics

- Use theme.json for all design tokens
- Keep templates minimal (use template parts)
- Prefer block patterns over custom PHP templates


## File Organization

```
wp-boilerplate-fse/
├── bin/                    # Setup and automation scripts
├── wp-content/
│   ├── themes/theme-fse/
│   │   ├── _dev/          # Source files (SCSS, JS, Webpack)
│   │   ├── dist/          # Compiled assets
│   │   ├── inc/           # PHP functionality (modular)
│   │   ├── blocks/        # ACF blocks (if ACF is used)
│   │   ├── parts/         # Template parts
│   │   ├── templates/     # Page templates
│   │   └── theme.json     # FSE configuration
│   ├── mu-plugins/        # Must-use plugins
│   └── plugins/           # Regular plugins
└── .github/workflows/     # CI/CD automation
```

## Specific Instructions

### When creating shell scripts

- Check if running in correct environment (WordPress root)
- Validate WP-CLI availability
- Provide clear progress indicators
- Support both interactive and non-interactive modes
- Always log operations to a timestamped log file
- Clean up after yourself (remove temporary files)

### When working with theme PHP

- All functionality goes in /inc/ as modular files
- functions.php should only load files from /inc/
- One function = one responsibility
- Prefix everything: functions, hooks, scripts, styles
- Security: think like an attacker, code defensively
- Use BEM for CSS classes
- Escape all outputs, sanitize all inputs
- Use i18n functions for strings with the theme text domain

### When creating blocks

- Use ACF block.json registration
- Each block gets its own folder in _dev/blocks/
- Structure: block.php, block.scss, block.js, block.json
- Webpack automatically compiles theme assets
- Use semantic HTML, accessible markup with ARIA roles and attributes

### When updating workflows

- Test in staging environment first
- Use GitHub Secrets for credentials (never hardcode)
- Exclude development files from deployment
- Add health checks after deployment
- Provide deployment summaries

## Common Patterns

### Adding a new PHP module

```php
<?php
/**
 * Brief description of what this file does
 * 
 * @package StudioVal_Boilerplate
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Function description
 *
 * @param string $param Description
 * @return void
 */
function studio_my_function($param) {
    // Implementation
}
add_action('hook_name', 'studio_my_function');
```

### Adding a setup script feature:

```bash
# 1. Add flag parsing
case $arg in
    --my-flag)    MY_FLAG=true;    shift ;;
esac

# 2. Add to help text
echo "  --my-flag         Description of flag"

# 3. Add logging
log_step "🚀 DOING SOMETHING"
echo "Detailed info about the step..."

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would perform action"
else
    # Actual implementation
    log_success "Action completed"
fi
```

## What to Avoid

- ❌ Inline styles or scripts in PHP
- ❌ Hardcoded URLs, paths, or credentials
- ❌ Modifying WordPress core files
- ❌ Using deprecated WordPress functions
- ❌ Adding unnecessary dependencies
- ❌ Breaking changes without major version bump
- ❌ Shell scripts without error handling
- ❌ Copying code without understanding it

## Testing Checklist

Before suggesting code changes, verify:

- Code follows WordPress coding standards
- Security: all user input is sanitized/escaped
- Shell scripts work in dry-run mode
- No hardcoded values (use variables/constants)
- Proper error handling
- Clear user feedback/logging
- Documentation updated if needed

## Questions to Ask
When unsure about implementation:

- "Is this for development or production?"
- "Should this be optional or mandatory?"
- "What happens if X fails?"
- "Do we need to support legacy WordPress/PHP versions?"
- "Should this be logged?"
- "Is there a simpler way to achieve this?"

## Helpful Context

- Primary user: WordPress developers (including the author)
- Target WP version: 6.0+
- PHP version: 8.0+
- Development tools: Local by Flywheel, WP-CLI, NPM
- Deployment: GitHub Actions → FTP
- Main use: Custom client sites by Studio Val