#!/bin/bash

# WordPress FSE Boilerplate Setup Script
# Sets up the theme and installs dependencies.
# Designed for use with ddev (self-contained structure: WordPress = repo root).

set -e  # Exit on any error

# ========== FUNCTIONS ==========
error_exit() {
  echo "❌ Error: $1" >&2
  echo "💡 Use --dry-run to test the setup without making changes" >&2
  exit 1
}

log_step() {
  echo ""
  echo "=========================================="
  echo "$1"
  echo "=========================================="
}

# Enhanced logging functions
setup_logging() {
  # Create logs directory if it doesn't exist
  local log_dir="$TARGET_ROOT/logs"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$log_dir"
  fi
  
  # Set log file path with timestamp
  LOG_FILE="$log_dir/setup-$(date +%Y%m%d-%H%M%S).log"
  
  if [ "$DRY_RUN" = false ]; then
    touch "$LOG_FILE"
    echo "📝 Logging setup process to: $LOG_FILE"
  else
    echo "[DRY RUN] Would create log file: $LOG_FILE"
  fi
}

log_info() {
  local message="$1"
  echo "ℹ️  $message"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $message" >> "$LOG_FILE"
  fi
}

log_success() {
  local message="$1"
  echo "✅ $message"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $message" >> "$LOG_FILE"
  fi
}

log_warning() {
  local message="$1"
  echo "⚠️  $message"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $message" >> "$LOG_FILE"
  fi
}

log_error() {
  local message="$1"
  echo "❌ $message" >&2
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $message" >> "$LOG_FILE"
  fi
}

# Summary logging functions
setup_summary() {
  SETUP_START_TIME=$(date +%s)
  SETUP_ERRORS=0
  SETUP_WARNINGS=0
  SETUP_SUCCESS_COUNT=0
}

increment_errors() {
  SETUP_ERRORS=$((SETUP_ERRORS + 1))
}

increment_warnings() {
  SETUP_WARNINGS=$((SETUP_WARNINGS + 1))
}

increment_success() {
  SETUP_SUCCESS_COUNT=$((SETUP_SUCCESS_COUNT + 1))
}

show_setup_summary() {
  local end_time=$(date +%s)
  local duration=$((end_time - SETUP_START_TIME))
  local minutes=$((duration / 60))
  local seconds=$((duration % 60))
  
  echo ""
  echo "=========================================="
  echo "🎉 SETUP COMPLETED"
  echo "=========================================="
  echo "⏱️  Duration: ${minutes}m ${seconds}s"
  echo "✅ Successful operations: $SETUP_SUCCESS_COUNT"
  echo "⚠️  Warnings: $SETUP_WARNINGS"
  echo "❌ Errors: $SETUP_ERRORS"
  
  if [ "$SETUP_ERRORS" -eq 0 ] && [ "$SETUP_WARNINGS" -eq 0 ]; then
    echo ""
    echo "🚀 Perfect setup! No issues encountered."
  elif [ "$SETUP_ERRORS" -eq 0 ]; then
    echo ""
    echo "✅ Setup completed successfully with minor warnings."
  else
    echo ""
    echo "⚠️  Setup completed with some errors. Check the log for details."
  fi
  
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "📝 Full log available at: $LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUMMARY: Setup completed - Duration: ${minutes}m ${seconds}s - Success: $SETUP_SUCCESS_COUNT - Warnings: $SETUP_WARNINGS - Errors: $SETUP_ERRORS" >> "$LOG_FILE"
  fi
}

# Function to install ACF Pro
install_acf_pro() {
  local license_key="$1"
  
  if [ -z "$license_key" ]; then
    echo "⚠️  No ACF Pro license key provided - skipping ACF Pro installation"
    echo "💡 Use --acf-license=YOUR_KEY or set ACF_PRO_LICENSE environment variable"
    return 1
  fi
  
  echo "🔑 Installing ACF Pro with license key..."
  
  # Use WP-CLI to install ACF Pro directly from the download URL
  local download_url="https://connect.advancedcustomfields.com/v2/plugins/download?p=pro&s=plugin&k=${license_key}"
  
  # Try to install ACF Pro, but don't let failures crash the script
  set +e  # Temporarily disable exit on error
  $WP plugin install "$download_url" --activate 2>/dev/null
  local install_result=$?
  set -e  # Re-enable exit on error
  
  if [ $install_result -eq 0 ]; then
    echo "✅ ACF Pro installed and activated successfully"
    
    # Set the license key in WordPress
    set +e  # Temporarily disable exit on error for license key setting
    $WP option update acf_pro_license "$license_key" 2>/dev/null
    local license_result=$?
    set -e  # Re-enable exit on error
    
    if [ $license_result -eq 0 ]; then
      echo "✅ ACF Pro license key configured"
    else
      echo "⚠️  ACF Pro installed but license key configuration failed"
      echo "💡 You may need to enter the license key manually in WordPress admin"
    fi
    
    return 0
  else
    echo "❌ Failed to install ACF Pro - check your license key and internet connection"
    return 1
  fi
}

# Cross-platform in-place sed (BSD/macOS requires -i '', GNU/Linux uses -i)
sed_inplace() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Function to convert theme slug to display name
# Example: "lemon-studio" → "Lemon Studio"
slug_to_display_name() {
  local slug="$1"
  # Replace hyphens and underscores with spaces, then capitalize each word
  echo "$slug" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1'
}

# Function to update theme information in style.css
update_theme_info() {
  local theme_path="$1"
  local theme_slug="$2"
  local style_css="$theme_path/style.css"

  # Compute names regardless of dry-run so they can be printed
  local display_name
  display_name=$(slug_to_display_name "$theme_slug")
  local text_domain
  text_domain=$(echo "$theme_slug" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')

  local block_categories="$theme_path/inc/block-categories.php"
  local make_block="$theme_path/_dev/scripts/make-block.js"

  echo "📝 Updating theme information in style.css..."
  echo "   Theme Name: WP FSE Boilerplate → $display_name"
  echo "   Theme URI: ending with /$theme_slug"
  echo "   Text Domain: fse-boilerplate → $text_domain"

  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would update theme name to '$display_name' in $style_css"
    echo "[DRY RUN] Would update theme URI to end with '/$theme_slug'"
    echo "[DRY RUN] Would update text domain to '$text_domain'"
    echo "[DRY RUN] Would update block categories slugs and labels in $block_categories"
    echo "[DRY RUN] Would update make-block script placeholders in $make_block"
    return 0
  fi

  if [ ! -f "$style_css" ]; then
    echo "⚠️  style.css not found at $style_css - skipping theme info update"
    return 1
  fi

  # Update Theme Name (handle both possible current names)
  sed_inplace "s/^Theme Name: WP Boilerplate FSE/Theme Name: $display_name/" "$style_css"
  sed_inplace "s/^Theme Name: WP FSE Boilerplate/Theme Name: $display_name/" "$style_css"

  # Update Theme URI to end with the theme slug
  sed_inplace "s|^Theme URI: .*|Theme URI: https://github.com/valentin-grenier/$theme_slug|" "$style_css"

  # Update Text Domain
  sed_inplace "s/^Text Domain: .*/Text Domain: $text_domain/" "$style_css"

  echo "✅ Theme information updated successfully"

  # Update block categories file
  if [ -f "$block_categories" ]; then
    sed_inplace "s/'theme-name'/'$text_domain'/g" "$block_categories"
    sed_inplace "s/'Theme Name'/'$display_name'/g" "$block_categories"
    echo "✅ Block categories updated successfully"
  else
    echo "⚠️  block-categories.php not found - skipping"
  fi

  # Update make-block script
  if [ -f "$make_block" ]; then
    sed_inplace "s/'theme-name'/'$text_domain'/g" "$make_block"
    sed_inplace "s/wp-block-theme-name-/wp-block-$text_domain-/g" "$make_block"
    echo "✅ make-block script updated successfully"
  else
    echo "⚠️  make-block.js not found - skipping"
  fi
}

# Function to update GitHub workflow files with the correct theme name
update_workflow_files() {
  local theme_slug="$1"
  local target_root="$2"
  
  echo "⚙️  Updating GitHub workflow files..."
  
  local staging_workflow="$target_root/.github/workflows/deploy-staging.yml"
  local production_workflow="$target_root/.github/workflows/deploy-production.yml"
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would update theme paths in GitHub workflow files:"
    echo "[DRY RUN]   theme-fse → $theme_slug in deploy-staging.yml"
    echo "[DRY RUN]   theme-fse → $theme_slug in deploy-production.yml"
    return 0
  fi
  
  # Update staging workflow
  if [ -f "$staging_workflow" ]; then
    sed_inplace "s|wp-content/themes/theme-fse/|wp-content/themes/$theme_slug/|g" "$staging_workflow"
    echo "✅ Updated deploy-staging.yml with theme name: $theme_slug"
  else
    echo "⚠️  deploy-staging.yml not found - skipping"
  fi
  
  # Update production workflow
  if [ -f "$production_workflow" ]; then
    sed_inplace "s|wp-content/themes/theme-fse/|wp-content/themes/$theme_slug/|g" "$production_workflow"
    echo "✅ Updated deploy-production.yml with theme name: $theme_slug"
  else
    echo "⚠️  deploy-production.yml not found - skipping"
  fi
}

# ========== CONFIG ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ROOT="$REPO_DIR"
WP_CONTENT="$REPO_DIR/wp-content"
WP_PATH="$REPO_DIR"

DRY_RUN=false
SKIP_PLUGINS=false
THEME_SLUG=""
THEME_DEST=""
ACF_LICENSE_KEY=""

# ========== FLAGS ==========
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)       DRY_RUN=true ;;
    --skip-plugins)  SKIP_PLUGINS=true ;;
    --theme=*)       THEME_SLUG="${1#*=}" ;;
    --theme-dest=*)  THEME_DEST="${1#*=}" ;;
    --acf-license=*) ACF_LICENSE_KEY="${1#*=}" ;;
    --help|-h)
      echo "WordPress FSE Boilerplate Setup Script"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run             Show what would be done without making changes"
      echo "  --skip-plugins        Skip automatic plugin installation"
      echo "  --theme=NAME          Override source theme name detection"
      echo "  --theme-dest=NAME     Override destination theme name"
      echo "  --acf-license=KEY     ACF Pro license key for installation"
      echo "  --help, -h            Show this help message"
      echo ""
      echo "Environment Variables:"
      echo "  ACF_PRO_LICENSE       ACF Pro license key (alternative to --acf-license)"
      echo ""
      echo "ACF Pro License Sources (in order of precedence):"
      echo "  1. --acf-license=KEY command line flag"
      echo "  2. ACF_PRO_LICENSE environment variable"
      echo "  3. auth.json file (password field for connect.advancedcustomfields.com)"
      echo ""
      echo "Designed for ddev projects. Renames the theme in place, updates theme metadata,"
      echo "and installs dependencies."
      echo ""
      echo "Theme customization:"
      echo "  • Renames theme folder (e.g., theme-fse → my-project)"
      echo "  • Updates Theme Name, Theme URI, and Text Domain in style.css"
      echo "  • Updates text domain in block categories and make-block script"
      exit 0
      ;;
    *)  ;; # ignore unknown flags
  esac
  shift
done

# Check for ACF license in environment variable if not provided via flag
if [ -z "$ACF_LICENSE_KEY" ] && [ -n "$ACF_PRO_LICENSE" ]; then
  ACF_LICENSE_KEY="$ACF_PRO_LICENSE"
fi

# Check for ACF license in auth.json file
if [ -z "$ACF_LICENSE_KEY" ] && [ -f "$REPO_DIR/auth.json" ]; then
  if command -v jq &> /dev/null; then
    ACF_LICENSE_KEY=$(jq -r '.["http-basic"]["connect.advancedcustomfields.com"].password // empty' "$REPO_DIR/auth.json" 2>/dev/null)
    if [ -n "$ACF_LICENSE_KEY" ] && [ "$ACF_LICENSE_KEY" != "null" ]; then
      echo "🔑 Found ACF Pro license in auth.json"
    else
      ACF_LICENSE_KEY=""
    fi
  fi
fi

# ========== ENV DETECTION & WP-CLI CHECK ==========
if [[ "$(uname -s)" == *"MINGW"* || "$(uname -s)" == *"NT"* ]]; then
  WP="cmd //c wp"
elif command -v ddev &>/dev/null && ddev status 2>/dev/null | grep -q "running"; then
  WP="ddev wp"
else
  WP="wp"
fi

if ! command -v ${WP%% *} &> /dev/null; then
  error_exit "WP-CLI introuvable. Lance 'ddev start' puis relance ce script, ou installe WP-CLI globalement."
fi

# ========== INITIALIZE LOGGING AND SUMMARY ==========
setup_summary
setup_logging

# ========== VALIDATION ==========
log_step "🔍 VALIDATING ENVIRONMENT"

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  error_exit "wp-config.php not found in $WP_PATH — check your WP_PATH."
fi

echo "✅ WordPress installation found at: $WP_PATH"

# ========== THEME AUTO-DETECT & RENAME ==========
log_step "🎨 THEME SETUP"

# 1) Auto-detect the one source theme folder
SLUGS=()
while IFS= read -r slug; do
  SLUGS+=("$slug")
done < <(find "$WP_CONTENT/themes" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
if    [ ${#SLUGS[@]} -eq 0 ]; then
  echo "ℹ️  No theme folder found in $WP_CONTENT/themes/"
  echo "🔍 Checking if setup has already been completed..."
  
  if [ -d "$WP_CONTENT/themes" ]; then
    echo "✅ Found existing themes in WordPress installation"
    echo "💡 It appears the setup may have already been completed"
    
    if [ "$DRY_RUN" = true ]; then
      echo ""
      echo "🔍 DRY RUN completed - setup appears to already be done"
      exit 0
    else
      echo ""
      echo "❓ Do you want to continue with plugin installation only? (y/n)"
      read -r continue_plugins
      if [[ "$continue_plugins" =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping theme setup, proceeding to plugin installation..."
        SKIP_THEME=true
      else
        echo "⏹️  Setup cancelled"
        exit 0
      fi
    fi
  else
    error_exit "No theme folder found in $WP_CONTENT/themes/"
  fi
elif  [ ${#SLUGS[@]} -eq 1 ]; then
  THEME_SRC="${SLUGS[0]}"
  echo "🎨 Auto-detected source theme: $THEME_SRC"
else
  echo "🎨 Multiple themes found:"
  for s in "${SLUGS[@]}"; do echo "  – $s"; done
  read -p "Enter the source theme to rename: " input_src
  THEME_SRC="$input_src"
fi

# 2) Determine destination slug
SKIP_THEME=${SKIP_THEME:-false}
if [ "$SKIP_THEME" = false ]; then
  if [ -z "$THEME_DEST" ]; then
    read -p "Enter target theme folder name (default: $THEME_SRC): " input_dest
    THEME_DEST="${input_dest:-$THEME_SRC}"
    echo "🎨 Will rename theme to: $THEME_DEST"
  else
    echo "🎨 Using provided target theme slug: $THEME_DEST"
  fi

  # 3) Paths
  THEME_SOURCE="$WP_CONTENT/themes/$THEME_SRC"
  THEME_TARGET="$WP_CONTENT/themes/$THEME_DEST"

  # 4) Rename
  if [ -d "$THEME_SOURCE" ]; then
    if [ "$THEME_SRC" != "$THEME_DEST" ]; then
      echo "📦 Renaming '$THEME_SRC' → '$THEME_DEST' ..."
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] mv \"$THEME_SOURCE\" \"$THEME_TARGET\""
      else
        mv "$THEME_SOURCE" "$THEME_TARGET"
        echo "✅ Theme renamed to: $THEME_DEST"
      fi
    else
      echo "ℹ️  Theme slug unchanged: $THEME_DEST"
    fi

    # Update theme information in style.css
    update_theme_info "$THEME_TARGET" "$THEME_DEST"

    # Update GitHub workflow files with the new theme name
    update_workflow_files "$THEME_DEST" "$TARGET_ROOT"
  else
    echo "⚠️  Source theme '$THEME_SRC' not found — skipping"
  fi
else
  echo "⏭️  Skipping theme setup (already completed)"
fi

# ========== INSTALL DEVELOPMENT DEPENDENCIES ==========
THEME_DEV_DIR="$WP_CONTENT/themes/$THEME_DEST/_dev"
if [ "$DRY_RUN" = false ] && [ -d "$THEME_DEV_DIR" ] && [ -f "$THEME_DEV_DIR/package.json" ]; then
  log_step "📦 INSTALLING DEVELOPMENT DEPENDENCIES"
  
  echo "📦 Installing theme development dependencies..."
  cd "$THEME_DEV_DIR"
  
  if command -v npm &> /dev/null; then
    if npm install; then
      echo "✅ NPM dependencies installed successfully"
      
      # Build assets
      echo "🔨 Building theme assets..."
      if npm run build; then
        echo "✅ Theme assets built successfully"
      else
        echo "⚠️  Failed to build assets - you may need to run 'npm run build' manually"
      fi
    else
      echo "⚠️  Failed to install NPM dependencies"
    fi
  else
    echo "⚠️  NPM not found - skipping dependency installation"
    echo "👉 Run 'npm install && npm run build' in $THEME_DEV_DIR later"
  fi
fi

# ========== INSTALL RECOMMENDED PLUGINS ==========
if [ "$DRY_RUN" = false ] && [ "$SKIP_PLUGINS" != true ]; then
  log_step "🔌 INSTALLING RECOMMENDED PLUGINS"
  
  cd "$WP_PATH"
  
  # Install ACF Pro first if license key is provided
  if [ -n "$ACF_LICENSE_KEY" ]; then
    echo "� Installing ACF Pro..."
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would install ACF Pro with provided license key"
    else
      if install_acf_pro "$ACF_LICENSE_KEY"; then
        echo "✅ ACF Pro installation completed successfully"
      else
        echo "⚠️  ACF Pro installation failed - continuing with other plugins"
        echo "💡 You can install ACF Pro manually later from the WordPress admin"
      fi
    fi
    echo ""
  fi
  
  echo "🔌 Installing recommended development plugins..."
  
  # Development plugins
  DEV_PLUGINS=(
    "query-monitor"
    "updraftplus"
    "admin-site-enhancements"
    "contact-form-7"
    "contact-form-7-honeypot"
  )
  
  for plugin in "${DEV_PLUGINS[@]}"; do
    echo "  Installing $plugin..."
    if [ "$DRY_RUN" = true ]; then
      echo "  [DRY RUN] Would install and activate $plugin"
    else
      if $WP plugin install "$plugin" --activate 2>/dev/null; then
        echo "  ✅ $plugin installed and activated"
      else
        echo "  ⚠️  Failed to install $plugin - may already exist or network issue"
      fi
    fi
  done
  
  # Production plugins (installed but not activated)
  PROD_PLUGINS=(
    "broken-link-checker"
    "seo-by-rank-math"
    "complianz-gdpr"
    "webp-converter-for-media"
    "simple-history"
    "plausible-analytics",
    "wp-mail-smtp"
    "better-wp-security"
  )

  echo ""
  echo "🔌 Installing production plugins (not activated)..."

  for plugin in "${PROD_PLUGINS[@]}"; do
    echo "  Installing $plugin..."
    if [ "$DRY_RUN" = true ]; then
      echo "  [DRY RUN] Would install $plugin (without activating)"
    else
      if $WP plugin install "$plugin" 2>/dev/null; then
        echo "  ✅ $plugin installed (not activated)"
      else
        echo "  ⚠️  Failed to install $plugin - may already exist or network issue"
      fi
    fi
  done

  echo ""
  echo "💡 Activate production plugins when ready: $WP plugin activate <plugin-name>"
fi

# ========== ACTIVATE THEME ==========
if [ "$DRY_RUN" = false ]; then
  log_step "🎨 ACTIVATING THEME"
  
  cd "$WP_PATH"
  
  echo "🎨 Activating theme: $THEME_DEST..."
  
  if $WP theme activate "$THEME_DEST" 2>/dev/null; then
    echo "✅ Theme '$THEME_DEST' activated successfully"
    
    # Verify theme activation
    active_theme=$($WP theme list --status=active --field=name 2>/dev/null)
    if [ "$active_theme" = "$THEME_DEST" ]; then
      echo "✅ Theme activation verified"
    else
      echo "⚠️  Theme activation may not have completed properly"
      echo "💡 Active theme: $active_theme"
    fi
  else
    echo "⚠️  Failed to activate theme '$THEME_DEST'"
    echo "💡 You can activate it manually from WordPress admin: Appearance → Themes"
    echo "👉 Or run: $WP theme activate $THEME_DEST"
  fi
fi

# ========== SUCCESS MESSAGE ==========
if [ "$DRY_RUN" = false ]; then
  echo ""
  echo "🎉 Setup completed successfully!"
  echo ""
  echo "📍 WordPress (ddev): $WP_PATH"
  echo "🎨 Theme: $WP_CONTENT/themes/$THEME_DEST"
  echo "⚙️  Dev files: $WP_CONTENT/themes/$THEME_DEST/_dev"
  echo ""
  echo "🚀 Next steps:"
  echo "   1. Visit your WordPress admin: $(ddev describe -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['raw']['primary_url'])" 2>/dev/null || echo "https://$(basename $WP_PATH).ddev.site")/wp-admin"
  echo "   2. Customize your theme in: $WP_CONTENT/themes/$THEME_DEST"
  echo "   3. Start dev: cd $WP_CONTENT/themes/$THEME_DEST/_dev && npm run watch"
  echo ""
else
  echo ""
  echo "🔍 DRY RUN completed - no actual changes made"
  echo "   Remove --dry-run flag to execute the setup"
fi

# ========== SHOW SETUP SUMMARY ==========
show_setup_summary
