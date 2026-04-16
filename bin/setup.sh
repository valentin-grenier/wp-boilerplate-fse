#!/bin/bash

# WordPress FSE Boilerplate Setup Script
# Sets up the theme and installs dependencies.
# Designed for use with ddev (self-contained structure: WordPress = repo root).

set -e  # Exit on any error

# ========== COLORS ==========
if [[ -t 1 ]]; then
  C_RED='\033[0;31m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[0;33m'
  C_BLUE='\033[0;34m'
  C_MAGENTA='\033[0;35m'
  C_CYAN='\033[0;36m'
  C_BOLD='\033[1m'
  C_RESET='\033[0m'
else
  C_RED='' C_GREEN='' C_YELLOW='' C_BLUE=''
  C_MAGENTA='' C_CYAN='' C_BOLD='' C_RESET=''
fi

# Delay between log lines (seconds). Set to 0 to disable.
LOG_DELAY=0.05

# ========== FUNCTIONS ==========
error_exit() {
  echo -e "${C_RED}❌ Error: $1${C_RESET}" >&2
  echo -e "${C_YELLOW}💡 Use --dry-run to test the setup without making changes${C_RESET}" >&2
  exit 1
}

log_step() {
  echo ""
  sleep "$LOG_DELAY"
  echo -e "${C_BOLD}${C_CYAN}==========================================${C_RESET}"
  sleep "$LOG_DELAY"
  echo -e "${C_BOLD}${C_CYAN}$1${C_RESET}"
  sleep "$LOG_DELAY"
  echo -e "${C_BOLD}${C_CYAN}==========================================${C_RESET}"
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
  sleep "$LOG_DELAY"
  echo -e "${C_BLUE}ℹ️  $message${C_RESET}"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $message" >> "$LOG_FILE"
  fi
}

log_success() {
  local message="$1"
  sleep "$LOG_DELAY"
  echo -e "${C_GREEN}✅ $message${C_RESET}"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $message" >> "$LOG_FILE"
  fi
}

log_warning() {
  local message="$1"
  sleep "$LOG_DELAY"
  echo -e "${C_YELLOW}⚠️  $message${C_RESET}"
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $message" >> "$LOG_FILE"
  fi
}

log_error() {
  local message="$1"
  sleep "$LOG_DELAY"
  echo -e "${C_RED}❌ $message${C_RESET}" >&2
  if [ "$DRY_RUN" = false ] && [ -n "$LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $message" >> "$LOG_FILE"
  fi
}

# Spinner
SPINNER_PID=""

start_spinner() {
  [[ -t 1 ]] || return
  local message="$1"
  local frames=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
  local i=0
  while true; do
    printf "\r${C_CYAN}%s${C_RESET}  %s" "${frames[i]}" "$message"
    i=$(( (i + 1) % 8 ))
    sleep 0.08
  done &
  SPINNER_PID=$!
}

stop_spinner() {
  if [ -n "$SPINNER_PID" ]; then
    kill "$SPINNER_PID" 2>/dev/null
    wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r\033[K"
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
    log_warning "No ACF Pro license key provided - skipping ACF Pro installation"
    echo "💡 Use --acf-license=YOUR_KEY or set ACF_PRO_LICENSE environment variable"
    increment_warnings
    return 1
  fi
  
  log_info "Installing ACF Pro with license key..."
  
  # Use WP-CLI to install ACF Pro directly from the download URL
  local download_url="https://connect.advancedcustomfields.com/v2/plugins/download?p=pro&s=plugin&k=${license_key}"
  
  # Try to install ACF Pro, but don't let failures crash the script
  set +e  # Temporarily disable exit on error
  $WP plugin install "$download_url" --activate 2>/dev/null
  local install_result=$?
  set -e  # Re-enable exit on error
  
  if [ $install_result -eq 0 ]; then
    log_success "ACF Pro installed and activated successfully"
    increment_success
    
    # Set the license key in WordPress
    set +e  # Temporarily disable exit on error for license key setting
    $WP option update acf_pro_license "$license_key" 2>/dev/null
    local license_result=$?
    set -e  # Re-enable exit on error
    
    if [ $license_result -eq 0 ]; then
      log_success "ACF Pro license key configured"
      increment_success
    else
      log_warning "ACF Pro installed but license key configuration failed"
      echo "💡 You may need to enter the license key manually in WordPress admin"
      increment_warnings
    fi
    
    return 0
  else
    log_error "Failed to install ACF Pro - check your license key and internet connection"
    increment_errors
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

  log_info "Updating theme information in style.css..."
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
    log_warning "style.css not found at $style_css - skipping theme info update"
    increment_warnings
    return 1
  fi

  # Update Theme Name (handle both possible current names)
  sed_inplace "s/^Theme Name: WP Boilerplate FSE/Theme Name: $display_name/" "$style_css"
  sed_inplace "s/^Theme Name: WP FSE Boilerplate/Theme Name: $display_name/" "$style_css"

  # Update Theme URI to end with the theme slug
  sed_inplace "s|^Theme URI: .*|Theme URI: https://github.com/valentin-grenier/$theme_slug|" "$style_css"

  # Update Text Domain
  sed_inplace "s/^Text Domain: .*/Text Domain: $text_domain/" "$style_css"

  log_success "Theme information updated successfully"
  increment_success

  # Update block categories file
  if [ -f "$block_categories" ]; then
    sed_inplace "s/'theme-name'/'$text_domain'/g" "$block_categories"
    sed_inplace "s/'Theme Name'/'$display_name'/g" "$block_categories"
    log_success "Block categories updated successfully"
    increment_success
  else
    log_warning "block-categories.php not found - skipping"
    increment_warnings
  fi

  # Update make-block script
  if [ -f "$make_block" ]; then
    sed_inplace "s/'theme-name'/'$text_domain'/g" "$make_block"
    sed_inplace "s/wp-block-theme-name-/wp-block-$text_domain-/g" "$make_block"
    log_success "make-block script updated successfully"
    increment_success
  else
    log_warning "make-block.js not found - skipping"
    increment_warnings
  fi
}

# Function to update GitHub workflow files with the correct theme name
update_workflow_files() {
  local theme_slug="$1"
  local target_root="$2"
  
  log_info "Updating GitHub workflow files..."
  
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
    log_success "Updated deploy-staging.yml with theme name: $theme_slug"
    increment_success
  else
    log_warning "deploy-staging.yml not found - skipping"
    increment_warnings
  fi
  
  # Update production workflow
  if [ -f "$production_workflow" ]; then
    sed_inplace "s|wp-content/themes/theme-fse/|wp-content/themes/$theme_slug/|g" "$production_workflow"
    log_success "Updated deploy-production.yml with theme name: $theme_slug"
    increment_success
  else
    log_warning "deploy-production.yml not found - skipping"
    increment_warnings
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
trap 'stop_spinner' EXIT

# ========== VALIDATION ==========
log_step "🔍 VALIDATING ENVIRONMENT"

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  error_exit "wp-config.php not found in $WP_PATH — check your WP_PATH."
fi

log_success "WordPress installation found at: $WP_PATH"
increment_success

# ========== THEME AUTO-DETECT & RENAME ==========
log_step "🎨 THEME SETUP"

# 1) Auto-detect the one source theme folder
SLUGS=()
while IFS= read -r slug; do
  SLUGS+=("$slug")
done < <(find "$WP_CONTENT/themes" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
if    [ ${#SLUGS[@]} -eq 0 ]; then
  log_info "No theme folder found in $WP_CONTENT/themes/"
  log_info "Checking if setup has already been completed..."
  
  if [ -d "$WP_CONTENT/themes" ]; then
    log_success "Found existing themes in WordPress installation"
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
  log_info "Auto-detected source theme: $THEME_SRC"
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
    log_info "Will rename theme to: $THEME_DEST"
  else
    log_info "Using provided target theme slug: $THEME_DEST"
  fi

  # Validate theme slug (only allow lowercase letters, numbers, and hyphens)
  if [[ ! "$THEME_DEST" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    error_exit "Invalid theme slug '$THEME_DEST'. Use only lowercase letters, numbers, and hyphens (e.g., 'my-theme')."
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
        log_success "Theme renamed to: $THEME_DEST"
        increment_success
      fi
    else
      log_info "Theme slug unchanged: $THEME_DEST"
    fi

    # Update theme information in style.css
    update_theme_info "$THEME_TARGET" "$THEME_DEST"

    # Update GitHub workflow files with the new theme name
    update_workflow_files "$THEME_DEST" "$TARGET_ROOT"
  else
    log_warning "Source theme '$THEME_SRC' not found — skipping"
    increment_warnings
  fi
else
  log_info "Skipping theme setup (already completed)"
fi

# ========== INSTALL DEVELOPMENT DEPENDENCIES ==========
THEME_DEV_DIR="$WP_CONTENT/themes/$THEME_DEST/_dev"
if [ "$DRY_RUN" = false ] && [ -d "$THEME_DEV_DIR" ] && [ -f "$THEME_DEV_DIR/package.json" ]; then
  log_step "📦 INSTALLING DEVELOPMENT DEPENDENCIES"
  
  cd "$THEME_DEV_DIR"
  
  if command -v npm &> /dev/null; then
    start_spinner "Installing npm dependencies..."
    if npm install >/dev/null 2>&1; then
      stop_spinner
      log_success "NPM dependencies installed successfully"
      increment_success
      
      # Build assets
      start_spinner "Building theme assets..."
      if npm run build >/dev/null 2>&1; then
        stop_spinner
        log_success "Theme assets built successfully"
        increment_success
      else
        stop_spinner
        log_warning "Failed to build assets - you may need to run 'npm run build' manually"
        increment_warnings
      fi
    else
      stop_spinner
      log_warning "Failed to install NPM dependencies"
      increment_warnings
    fi
  else
    log_warning "NPM not found - skipping dependency installation"
    increment_warnings
    echo "👉 Run 'npm install && npm run build' in $THEME_DEV_DIR later"
  fi
fi

# ========== INSTALL RECOMMENDED PLUGINS ==========
if [ "$DRY_RUN" = false ] && [ "$SKIP_PLUGINS" != true ]; then
  log_step "🔌 INSTALLING RECOMMENDED PLUGINS"
  
  cd "$WP_PATH"
  
  # Install ACF Pro first if license key is provided
  if [ -n "$ACF_LICENSE_KEY" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would install ACF Pro with provided license key"
    else
      start_spinner "Installing ACF Pro..."
      if install_acf_pro "$ACF_LICENSE_KEY" >/dev/null 2>&1; then
        stop_spinner
        log_success "ACF Pro installed and activated successfully"
        increment_success
      else
        stop_spinner
        log_warning "ACF Pro installation failed - continuing with other plugins"
        increment_warnings
        echo "💡 You can install ACF Pro manually later from the WordPress admin"
      fi
    fi
    echo ""
  fi
  
  log_info "Installing recommended development plugins..."
  
  # Development plugins
  DEV_PLUGINS=(
    "query-monitor"
    "updraftplus"
    "admin-site-enhancements"
    "contact-form-7"
    "contact-form-7-honeypot"
  )
  
  for plugin in "${DEV_PLUGINS[@]}"; do
    if [ "$DRY_RUN" = true ]; then
      echo "  [DRY RUN] Would install and activate $plugin"
    else
      start_spinner "Installing $plugin..."
      if $WP plugin install "$plugin" --activate >/dev/null 2>&1; then
        stop_spinner
        log_success "$plugin installed and activated"
        increment_success
      else
        stop_spinner
        log_warning "Failed to install $plugin - may already exist or network issue"
        increment_warnings
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
    "plausible-analytics"
    "wp-mail-smtp"
    "better-wp-security"
  )

  echo ""
  log_info "Installing production plugins (not activated)..."

  for plugin in "${PROD_PLUGINS[@]}"; do
    if [ "$DRY_RUN" = true ]; then
      echo "  [DRY RUN] Would install $plugin (without activating)"
    else
      start_spinner "Installing $plugin..."
      if $WP plugin install "$plugin" >/dev/null 2>&1; then
        stop_spinner
        log_success "$plugin installed (not activated)"
        increment_success
      else
        stop_spinner
        log_warning "Failed to install $plugin - may already exist or network issue"
        increment_warnings
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
  
  start_spinner "Activating theme: $THEME_DEST..."
  
  if $WP theme activate "$THEME_DEST" >/dev/null 2>&1; then
    stop_spinner
    log_success "Theme '$THEME_DEST' activated successfully"
    increment_success
    
    # Verify theme activation
    active_theme=$($WP theme list --status=active --field=name 2>/dev/null)
    if [ "$active_theme" = "$THEME_DEST" ]; then
      log_success "Theme activation verified"
      increment_success
    else
      log_warning "Theme activation may not have completed properly"
      increment_warnings
      echo "💡 Active theme: $active_theme"
    fi
  else
    stop_spinner
    log_warning "Failed to activate theme '$THEME_DEST'"
    increment_warnings
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
