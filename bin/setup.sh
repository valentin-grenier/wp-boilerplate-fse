#!/bin/bash

# WordPress FSE Boilerplate Setup Script
# Moves boilerplate content to WordPress root and sets up development environment

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
  
  if [ ! -f "$style_css" ]; then
    echo "⚠️  style.css not found at $style_css - skipping theme info update"
    return 1
  fi
  
  # Convert slug to display name
  local display_name
  display_name=$(slug_to_display_name "$theme_slug")
  
  # Convert slug to text domain (WordPress standard: lowercase with hyphens)
  local text_domain
  text_domain=$(echo "$theme_slug" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')
  
  echo "📝 Updating theme information in style.css..."
  echo "   Theme Name: WP FSE Boilerplate → $display_name"
  echo "   Theme URI: ending with /$theme_slug"
  echo "   Text Domain: fse-boilerplate → $text_domain"
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would update theme name to '$display_name' in $style_css"
    echo "[DRY RUN] Would update theme URI to end with '/$theme_slug'"
    echo "[DRY RUN] Would update text domain to '$text_domain'"
  else
    # Update Theme Name (handle both possible current names)
    sed -i "s/^Theme Name: WP Boilerplate FSE/Theme Name: $display_name/" "$style_css"
    sed -i "s/^Theme Name: WP FSE Boilerplate/Theme Name: $display_name/" "$style_css"
    
    # Update Theme URI to end with the theme slug
    sed -i "s|^Theme URI: .*|Theme URI: https://github.com/valentin-grenier/$theme_slug|" "$style_css"
    
    # Update Text Domain
    sed -i "s/^Text Domain: .*/Text Domain: $text_domain/" "$style_css"
    
    echo "✅ Theme information updated successfully"
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
    sed -i "s|wp-content/themes/theme-fse/|wp-content/themes/$theme_slug/|g" "$staging_workflow"
    echo "✅ Updated deploy-staging.yml with theme name: $theme_slug"
  else
    echo "⚠️  deploy-staging.yml not found - skipping"
  fi
  
  # Update production workflow
  if [ -f "$production_workflow" ]; then
    sed -i "s|wp-content/themes/theme-fse/|wp-content/themes/$theme_slug/|g" "$production_workflow"
    echo "✅ Updated deploy-production.yml with theme name: $theme_slug"
  else
    echo "⚠️  deploy-production.yml not found - skipping"
  fi
}

# Function for manual git setup (fallback when GitHub CLI is not available)
manual_git_setup() {
  echo ""
  read -p "   GitHub username or organization (default: $GITHUB_USERNAME): " input_username
  github_username="${input_username:-$GITHUB_USERNAME}"
  
  if [ -n "$github_username" ]; then
    # Set up remote origin
    remote_url="https://github.com/${github_username}/${repo_name}.git"
    echo "🔗 Setting up remote origin: $remote_url"
    git remote add origin "$remote_url"
    
    # Rename default branch to main (if needed)
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
      echo "🔄 Renaming branch to 'main'..."
      git branch -M main
    fi
    
    # Ask about pushing to remote
    echo ""
    echo "🚀 Ready to push to GitHub!"
    echo "   ⚠️  Make sure you create the repository '$repo_name' on GitHub first:"
    echo "   🔗 https://github.com/new"
    echo ""
    read -p "   Push to GitHub now? (y/n): " push_now
    
    if [[ "$push_now" =~ ^[Yy]$ ]]; then
      echo "📤 Pushing to GitHub..."
      if git push -u origin main; then
        echo "✅ Successfully pushed to GitHub!"
        echo "🔗 Repository URL: https://github.com/${github_username}/${repo_name}"
      else
        echo "⚠️  Push failed. Please:"
        echo "   1. Create the repository '$repo_name' on GitHub: https://github.com/new"
        echo "   2. Then run: git push -u origin main"
      fi
    else
      echo "💡 To push later:"
      echo "   1. Create repository on GitHub: https://github.com/new"
      echo "   2. Run: git push -u origin main"
    fi
  else
    echo "⏭️  Skipping remote setup. You can add it later with:"
    echo "   git remote add origin https://github.com/USERNAME/${repo_name}.git"
    echo "   git push -u origin main"
  fi
}

# ========== CONFIG ==========
# Default: look one level up from the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ROOT="$(dirname "$REPO_DIR")"
REPO_WP_CONTENT="$REPO_DIR/wp-content"
TARGET_WP_CONTENT="$TARGET_ROOT/wp-content"
WP_PATH="$TARGET_ROOT"

DRY_RUN=false
SKIP_PLUGINS=false
SKIP_FILE_MOVEMENT=false
SKIP_GIT=false
SKIP_BRANCHES=false
THEME_SLUG=""
GITHUB_USERNAME="valentin-grenier"
ACF_LICENSE_KEY="NTgyYmIyN2FjYjQyMjE0MDU4YzIxMDQ1ZjliMzYxOTliYzdiZTFiNzUwNWFhYTFkZTA1NDQ4"

# ========== FLAGS ==========
for arg in "$@"; do
  case $arg in
    --dry-run)       DRY_RUN=true;        shift ;;
    --skip-plugins)  SKIP_PLUGINS=true;   shift ;;
    --skip-git)      SKIP_GIT=true;       shift ;;
    --skip-branches) SKIP_BRANCHES=true;  shift ;;
    --theme=*)       THEME_SLUG="${arg#*=}"; shift ;;
    --github-user=*) GITHUB_USERNAME="${arg#*=}"; shift ;;
    --acf-license=*) ACF_LICENSE_KEY="${arg#*=}"; shift ;;
    --help|-h)       
      echo "WordPress FSE Boilerplate Setup Script"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run             Show what would be done without making changes"
      echo "  --skip-plugins        Skip automatic plugin installation"
      echo "  --skip-git            Skip git repository initialization"
      echo "  --skip-branches       Skip creating additional git branches (staging, development)"
      echo "  --theme=NAME          Override source theme name detection"
      echo "  --theme-dest=NAME     Override destination theme name"
      echo "  --github-user=USER    Override GitHub username (default: valentin-grenier)"
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
      echo "This script moves the boilerplate content to the WordPress root directory,"
      echo "activates the theme, installs dependencies, and sets up the development environment."
      echo ""
      echo "Theme customization:"
      echo "  • Automatically updates theme name in style.css (e.g., 'lemon-studio' → 'Lemon Studio')"
      echo "  • Updates theme URI to match the chosen theme name"
      exit 0
      ;;
    *)               # ignore other flags
                     ;;
  esac
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
else
  WP="wp"
fi

if ! command -v $WP &> /dev/null; then
  error_exit "WP-CLI not found in this shell. Run from Local's Site Shell or install WP-CLI globally."
fi

# ========== VALIDATION ==========
log_step "🔍 VALIDATING ENVIRONMENT"

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  error_exit "wp-config.php not found in $WP_PATH — check your WP_PATH."
fi

echo "✅ WordPress installation found at: $WP_PATH"

# ========== THEME AUTO-DETECT & RENAME ==========
log_step "🎨 THEME SETUP"

# Flags for rename override
THEME_DEST=""

# If you passed --theme-dest=foo, pick that up
for arg in "$@"; do
  case $arg in
    --theme-dest=*) THEME_DEST="${arg#*=}"; shift ;;
  esac
done

# 1) Auto-detect the one source theme folder
mapfile -t SLUGS < <(find "$REPO_WP_CONTENT/themes" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
if    [ ${#SLUGS[@]} -eq 0 ]; then
  echo "ℹ️  No theme folder found in $REPO_WP_CONTENT/themes/"
  echo "🔍 Checking if setup has already been completed..."
  
  # Check if there are any themes in the target directory that might be from this boilerplate
  if [ -d "$TARGET_WP_CONTENT/themes" ]; then
    echo "✅ Found existing themes in WordPress installation"
    echo "💡 It appears the setup may have already been completed"
    echo "   If you need to re-run the setup, please restore the boilerplate files first"
    
    if [ "$DRY_RUN" = true ]; then
      echo ""
      echo "🔍 DRY RUN completed - setup appears to already be done"
      echo "   No boilerplate files found to process"
      exit 0
    else
      echo ""
      echo "❓ Do you want to continue with plugin installation only? (y/n)"
      read -r continue_plugins
      if [[ "$continue_plugins" =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping file movement, proceeding to plugin installation..."
        SKIP_FILE_MOVEMENT=true
      else
        echo "⏹️  Setup cancelled"
        exit 0
      fi
    fi
  else
    error_exit "No theme folder found in $REPO_WP_CONTENT/themes/ and no target themes directory found"
  fi
elif  [ ${#SLUGS[@]} -eq 1 ]; then
  THEME_SRC="${SLUGS[0]}"
  echo "🎨 Auto-detected source theme: $THEME_SRC"
else
  echo "🎨 Multiple themes found:"
  for s in "${SLUGS[@]}"; do echo "  – $s"; done
  read -p "Enter the source theme to move: " input_src
  THEME_SRC="$input_src"
fi

# 2) Determine destination slug
if [ "$SKIP_FILE_MOVEMENT" = false ]; then
  if [ -z "$THEME_DEST" ]; then
    read -p "Enter target theme folder name (default: wp-boilerplate-fse): " input_dest
    THEME_DEST="${input_dest:-wp-boilerplate-fse}"
    echo "🎨 Will rename theme to: $THEME_DEST"
  else
    echo "🎨 Using provided target theme slug: $THEME_DEST"
  fi

  # 3) Paths
  THEME_SOURCE="$REPO_WP_CONTENT/themes/$THEME_SRC"
  THEME_TARGET="$TARGET_WP_CONTENT/themes/$THEME_DEST"

  # 4) Move
  if [ -d "$THEME_SOURCE" ]; then
    echo "📦 Moving '$THEME_SRC' → '$THEME_TARGET' ..."
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] mv \"$THEME_SOURCE\" \"$THEME_TARGET\""
    else
      mv "$THEME_SOURCE" "$THEME_TARGET"
      echo "✅ Theme moved (and renamed) to: $THEME_DEST"
    fi
    
    # Update theme information in style.css
    update_theme_info "$THEME_TARGET" "$THEME_DEST"
    
    # Update GitHub workflow files with the new theme name
    update_workflow_files "$THEME_DEST" "$TARGET_ROOT"
  else
    echo "⚠️  Source theme '$THEME_SRC' not found — skipping"
  fi
else
  echo "⏭️  Skipping theme file movement (already completed)"
fi

# ========== MOVE PLUGINS DIRECTORY CONTENT ==========
if [ "$SKIP_FILE_MOVEMENT" = false ]; then
  log_step "📁 MOVING PLUGINS"

  PLUGINS_SOURCE="$REPO_WP_CONTENT/plugins"
  PLUGINS_TARGET="$TARGET_WP_CONTENT/plugins"

  echo "📁 Preparing plugins directory at $PLUGINS_TARGET..."
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$PLUGINS_TARGET"
  else
    echo "[DRY RUN] Would mkdir -p $PLUGINS_TARGET"
  fi

  # Check if there's a .gitkeep file to move
  GITIGNORE_FILE="$PLUGINS_SOURCE/.gitkeep"
  if [ -f "$GITIGNORE_FILE" ]; then
    echo "📦 Moving .gitkeep from plugins/"
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would move $GITIGNORE_FILE → $PLUGINS_TARGET/.gitkeep"
    else
      mv "$GITIGNORE_FILE" "$PLUGINS_TARGET/.gitkeep"
      echo "✅ .gitkeep moved to plugins/"
    fi
  else
    echo "ℹ️ No plugins or .gitkeep to move"
  fi

  # ========== MOVE ROOT FILES ==========
  log_step "📁 MOVING ROOT FILES"

  echo "📁 Moving root files to $TARGET_ROOT..."

  FILES_TO_MOVE=(
    ".gitignore"
    "README.md"
    "composer.json"
    "composer.lock"
  )

  for file in "${FILES_TO_MOVE[@]}"; do
    SRC="$REPO_DIR/$file"
    DEST="$TARGET_ROOT/$file"

    if [ -e "$SRC" ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would move $file → $TARGET_ROOT/"
      else
        mv "$SRC" "$DEST"
        echo "✅ Moved $file"
      fi
    fi
  done
else
  echo "⏭️  Skipping file movement (already completed)"
fi

# ========== ACTIVATE THEME ==========
if [ "$DRY_RUN" = false ] && [ -n "$THEME_DEST" ]; then
  log_step "🎨 ACTIVATING THEME"
  
  echo "🎨 Activating theme '$THEME_DEST'..."
  cd "$WP_PATH"
  
  if $WP theme is-installed "$THEME_DEST" 2>/dev/null; then
    if $WP theme activate "$THEME_DEST"; then
      echo "✅ Theme '$THEME_DEST' activated successfully"
    else
      echo "⚠️  Failed to activate theme '$THEME_DEST' - you may need to activate it manually"
    fi
  else
    echo "⚠️  Theme '$THEME_DEST' not found - skipping activation"
  fi
fi

# ========== INSTALL DEVELOPMENT DEPENDENCIES ==========
THEME_DEV_DIR="$TARGET_WP_CONTENT/themes/$THEME_DEST/_dev"
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
  
  echo "�🔌 Installing recommended development plugins..."
  
  # Development plugins
  DEV_PLUGINS=(
    "query-monitor"
    "updraftplus"
    "admin-site-enhancements"
    "contact-form-7"
    "flamingo"
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
  
  echo ""
  echo "📝 Additional production plugins available (not auto-installed):"
  echo "  • broken-link-checker"
  echo "  • seo-by-rank-math"
  echo "  • better-wp-security"
  echo "  • complianz-gdpr"
  echo "  • webp-converter-for-media"
  echo "  • simple-history"
  echo "  • plausible-analytics"
  echo ""
  echo "👉 Install these manually when ready for production"
fi

# ========== CLEANUP BOILERPLATE DIRECTORY ==========
if [ "$DRY_RUN" = false ]; then
  log_step "🧹 CLEANING UP"
  
  echo "🧹 Cleaning up boilerplate directory..."
  
  # After successful setup, we can safely remove the boilerplate directory
  # since all files have been moved to the WordPress installation
  echo "  Removing boilerplate directory: $REPO_DIR"
  
  # Change to parent directory to avoid issues when deleting current directory
  cd "$TARGET_ROOT"
  
  # Force removal of the entire boilerplate directory
  rm -rf "$REPO_DIR"
  echo "✅ Boilerplate directory cleaned up"
  
  # Also remove cleanup.sh if it exists in the target directory
  if [ -f "$TARGET_ROOT/cleanup.sh" ]; then
    echo "  Removing separate cleanup.sh script..."
    rm -f "$TARGET_ROOT/cleanup.sh"
    echo "✅ cleanup.sh removed"
  fi
else
  echo ""
  echo "[DRY RUN] Would clean up boilerplate directory:"
  echo "  1. Change to parent directory: $TARGET_ROOT"
  echo "  2. Remove boilerplate directory: $REPO_DIR"
  echo "  3. Remove cleanup.sh if present"
fi

# ========== GIT REPOSITORY INITIALIZATION ==========
if [ "$DRY_RUN" = false ] && [ "$SKIP_GIT" = false ]; then
  log_step "🔄 INITIALIZING NEW GIT REPOSITORY"
  
  cd "$TARGET_ROOT"
  
  # Remove the old .git folder from boilerplate
  if [ -d ".git" ]; then
    echo "🗑️  Removing existing .git folder from boilerplate..."
    rm -rf ".git"
    echo "✅ Old git history removed"
  fi
  
  # Initialize new git repository
  echo "🆕 Initializing new git repository..."
  git init
  
  # Add all files to staging
  echo "📦 Adding files to git..."
  git add .
  
  # Create initial commit
  echo "💾 Creating initial commit..."
  git commit -m "Initial commit: WordPress FSE theme setup"
  
  # Create additional branches for development workflow
  if [ "$SKIP_BRANCHES" = false ]; then
    echo "🌿 Creating development branches..."
    
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would create 'staging' branch"
      echo "[DRY RUN] Would create 'development' branch"
      echo "[DRY RUN] Would create 'feature/initial-setup' branch"
      echo "[DRY RUN] Would switch back to 'main' branch"
    else
      # Create staging branch
      git checkout -b staging
      echo "✅ Created 'staging' branch"
      
      # Create development branch
      git checkout -b development
      echo "✅ Created 'development' branch"
      
      # Create feature branch template
      git checkout -b feature/initial-setup
      echo "✅ Created 'feature/initial-setup' branch"
      
      # Switch back to main branch
      git checkout main
      echo "🔄 Switched back to 'main' branch"
    fi
    
    echo ""
    echo "📋 Available branches:"
    echo "   • main (current) - production-ready code"
    echo "   • staging - pre-production testing"
    echo "   • development - active development"
    echo "   • feature/initial-setup - example feature branch"
    echo ""
  else
    echo "⏭️  Skipping branch creation (--skip-branches flag used)"
    echo ""
  fi
  
  # Prompt for repository name and setup remote
  echo ""
  echo "🔗 Git Repository Setup"
  echo "   Please provide your GitHub repository details:"
  echo ""
  read -p "   Repository name: " repo_name
  
  if [ -n "$repo_name" ]; then
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
      echo "✅ GitHub CLI detected"
      
      # Check if user is authenticated with GitHub CLI
      if gh auth status &> /dev/null; then
        echo "✅ GitHub authentication verified"
        
        # Ask for repository visibility
        echo ""
        echo "� Repository Visibility:"
        echo "   1. Public (recommended for open source)"
        echo "   2. Private"
        echo ""
        read -p "   Choose visibility (1 or 2, default: 1): " visibility_choice
        
        if [ "$visibility_choice" = "2" ]; then
          visibility_flag="--private"
          visibility_text="private"
        else
          visibility_flag="--public"
          visibility_text="public"
        fi
        
        # Create repository on GitHub using gh CLI
        echo "🆕 Creating $visibility_text repository '$repo_name' on GitHub..."
        if gh repo create "$repo_name" $visibility_flag --description "WordPress FSE theme project" --source=. --remote=origin --push; then
          echo "✅ Repository created and pushed to GitHub successfully!"
          echo "🔗 Repository URL: https://github.com/$(gh api user --jq .login)/${repo_name}"
        else
          echo "⚠️  Failed to create repository on GitHub"
          echo "💡 You can create it manually or run: gh repo create $repo_name"
        fi
      else
        echo "⚠️  GitHub CLI not authenticated"
        echo "💡 Please run: gh auth login"
        echo ""
        echo "� Falling back to manual setup..."
        manual_git_setup
      fi
    else
      echo "ℹ️  GitHub CLI not found"
      echo "💡 For automatic repo creation, install GitHub CLI: https://cli.github.com/"
      echo ""
      echo "🔄 Using manual setup..."
      manual_git_setup
    fi
  else
    echo "⏭️  No repository name provided. You can set up git manually later."
  fi
  
  echo ""
  echo "✅ Git repository initialized successfully!"
elif [ "$SKIP_GIT" = true ]; then
  echo ""
  echo "⏭️  Skipping git repository initialization (--skip-git flag used)"
else
  echo ""
  echo "[DRY RUN] Would initialize new git repository:"
  echo "  1. Remove existing .git folder"
  echo "  2. git init"
  echo "  3. git add ."
  echo "  4. git commit -m 'Initial commit: WordPress FSE theme setup'"
  echo "  5. Prompt for repository name"
  if command -v gh &> /dev/null; then
    echo "  6. [GitHub CLI] Automatically create repository on GitHub"
    echo "  7. [GitHub CLI] Set up remote origin and push"
  else
    echo "  6. [Manual] Prompt for GitHub username"
    echo "  7. [Manual] Set up remote origin"
    echo "  8. [Manual] Push to GitHub (after manual repo creation)"
  fi
fi

# ========== SUCCESS MESSAGE ==========
if [ "$DRY_RUN" = false ]; then
  echo ""
  echo "🎉 Setup completed successfully!"
  echo ""
  echo "📍 Your WordPress site is ready at: $WP_PATH"
  echo "🎨 Theme location: $TARGET_WP_CONTENT/themes/$THEME_DEST"
  echo "⚙️  Development files: $TARGET_WP_CONTENT/themes/$THEME_DEST/_dev"
  echo ""
  echo "🧹 Cleanup:"
  echo "   • Boilerplate directory removed"
  echo "   • Fresh WordPress installation ready"
  echo ""
  echo "🚀 Next steps:"
  echo "   1. Visit your WordPress admin to configure settings"
  echo "   2. Customize your theme in: $TARGET_WP_CONTENT/themes/$THEME_DEST"
  echo "   3. For development, run: cd $TARGET_WP_CONTENT/themes/$THEME_DEST/_dev && npm run watch"
  echo ""
  echo "📂 Git Repository:"
  echo "   • New git repository initialized"
  echo "   • Initial commit created"
  echo "   • Ready for version control"
  echo ""
  echo "💡 Pro tip: Use 'npm run dev' for live SCSS compilation during development"
  echo ""
else
  echo ""
  echo "🔍 DRY RUN completed - no actual changes made"
  echo "   Remove --dry-run flag to execute the setup"
fi
