#!/usr/bin/env bash
#
# WordPress FSE Boilerplate — project setup.
#
# Turns a fresh "Use this template" checkout into a named client project:
# renames the theme and the plugin scaffold, substitutes every boilerplate
# identifier, and repoints every config that hardcodes the old paths.
#
# Design rules (do not regress these):
#   * Strict mode. Every command substitution is guarded.
#   * Every prompt happens BEFORE the first mutation, and every prompt has a
#     non-interactive fallback (--yes + flags).
#   * Every step is idempotent and safe to re-run.
#   * --dry-run prints every action without performing any of them.
#   * Errors say what the user should do next.
#
# Usage: ./bin/setup.sh --help

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WP_CONTENT="$REPO_ROOT/wp-content"
THEMES_DIR="$WP_CONTENT/themes"
PLUGINS_DIR="$WP_CONTENT/plugins"

# The placeholder tokens this script consumes. Nothing else in the repo may
# hardcode them outside the manifest below.
PLACEHOLDER_THEME_SLUG="theme-fse"
PLACEHOLDER_THEME_DOMAIN="studioval-boilerplate"
PLACEHOLDER_THEME_PREFIX="sv_boilerplate_"
PLACEHOLDER_PLUGIN_SLUG="studioval-plugin-boilerplate"
BOILERPLATE_REPO="valentin-grenier/wp-boilerplate-fse"

MIN_PHP_VERSION="8.2"

# ----------------------------------------------------------------------------
# THE MANIFEST — single source of truth.
#
# Every file OUTSIDE wp-content/themes/<theme>/ and wp-content/plugins/<plugin>/
# that hardcodes a boilerplate path. Renaming the theme or the plugin without
# rewriting all of these leaves the project with a broken toolchain (phpcs,
# phpstan, phpunit and CI all resolving to a directory that no longer exists)
# and, via .gitignore, with the theme's committed dist/ silently untracked.
#
# Adding a new file that references the theme or plugin path? Add it here.
# verify_no_placeholders() fails the run if a placeholder survives in any of
# them, so this list cannot drift silently.
# ----------------------------------------------------------------------------
EXTERNAL_REFERENCE_FILES=(
    "phpcs.xml.dist"
    "phpstan.neon.dist"
    "phpunit.xml.dist"
    ".gitignore"
    ".github/dependabot.yml"
    ".github/workflows/ci.yml"
    ".github/workflows/deploy-staging.yml"
    ".github/workflows/deploy-production.yml"
    "bin/smoke.sh"
    "bin/reset-theme-json.sh"
    "LICENSE"
)

# Paths excluded from the final placeholder verification: historical records and
# agent/team documentation that intentionally keep describing the boilerplate.
VERIFY_EXCLUDES=(
    ".git"
    ".claude"
    "docs"
    "logs"
    "node_modules"
    "vendor"
    "dist"
    "CHANGELOG.md"
    "README.md"
    "setup.sh"
)

# ============================================================================
# GLOBAL STATE
# ============================================================================

DRY_RUN=false
ASSUME_YES=false
FORCE=false
SKIP_PLUGINS=false
SKIP_PLUGIN_BOILERPLATE=false
SKIP_BRANCHES=false
SKIP_CONTENT=false

THEME_SRC=""
THEME_DEST=""
THEME_PREFIX=""
PLUGIN_DEST=""
GITHUB_USER="valentin-grenier"

WP=""
LOG_FILE=""
SETUP_START_TIME=0
SETUP_ERRORS=0
SETUP_WARNINGS=0
SETUP_SUCCESS_COUNT=0

# ============================================================================
# LOGGING
# ============================================================================

if [ -t 1 ]; then
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'
    C_CYAN='\033[0;36m'
    C_DIM='\033[2m'
    C_BOLD='\033[1m'
    C_RESET='\033[0m'
else
    C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_CYAN='' C_DIM='' C_BOLD='' C_RESET=''
fi

_log_to_file() {
    [ -n "$LOG_FILE" ] || return 0
    [ "$DRY_RUN" = false ] || return 0
    printf '[%s] %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >>"$LOG_FILE"
}

log_step() {
    printf '\n%b%s%b\n' "${C_BOLD}${C_CYAN}" "── $1 ──────────────────────────────────" "$C_RESET"
    _log_to_file "STEP" "$1"
}

log_info()    { printf '%bℹ  %s%b\n' "$C_BLUE" "$1" "$C_RESET"; _log_to_file "INFO" "$1"; }
log_detail()  { printf '%b   %s%b\n' "$C_DIM" "$1" "$C_RESET"; _log_to_file "DETAIL" "$1"; }

log_success() {
    printf '%b✅ %s%b\n' "$C_GREEN" "$1" "$C_RESET"
    _log_to_file "SUCCESS" "$1"
    SETUP_SUCCESS_COUNT=$((SETUP_SUCCESS_COUNT + 1))
}

log_warning() {
    printf '%b⚠️  %s%b\n' "$C_YELLOW" "$1" "$C_RESET" >&2
    _log_to_file "WARNING" "$1"
    SETUP_WARNINGS=$((SETUP_WARNINGS + 1))
}

# Records a non-fatal error. Unlike the previous revision, this counter is
# actually wired up, so the final summary reflects what happened.
log_error() {
    printf '%b❌ %s%b\n' "$C_RED" "$1" "$C_RESET" >&2
    _log_to_file "ERROR" "$1"
    SETUP_ERRORS=$((SETUP_ERRORS + 1))
}

# die MESSAGE [NEXT_STEP...] — fatal, with actionable guidance.
die() {
    local message="$1"
    shift
    printf '\n%b❌ %s%b\n' "$C_RED" "$message" "$C_RESET" >&2
    if [ "$#" -gt 0 ]; then
        printf '%b👉 What to do next:%b\n' "$C_YELLOW" "$C_RESET" >&2
        local line
        for line in "$@"; do
            printf '   %s\n' "$line" >&2
        done
    fi
    if [ -n "$LOG_FILE" ] && [ "$DRY_RUN" = false ] && [ -f "$LOG_FILE" ]; then
        printf '\n%b📝 Full log: %s%b\n' "$C_DIM" "$LOG_FILE" "$C_RESET" >&2
    fi
    exit 1
}

setup_logging() {
    local log_dir="$REPO_ROOT/logs"
    LOG_FILE="$log_dir/setup-$(date +%Y%m%d-%H%M%S).log"
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    mkdir -p "$log_dir"
    : >"$LOG_FILE"
}

# ============================================================================
# EXECUTION HELPERS (dry-run aware)
# ============================================================================

# run CMD... — execute, or print under --dry-run.
run() {
    if [ "$DRY_RUN" = true ]; then
        printf '%b   [dry-run] %s%b\n' "$C_DIM" "$*" "$C_RESET"
        return 0
    fi
    "$@"
}

# Cross-platform in-place sed (BSD/macOS needs an explicit empty suffix).
sed_inplace() {
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# apply_sed FILE EXPR... — apply each expression in place, dry-run aware.
apply_sed() {
    local file="$1"
    shift
    if [ "$DRY_RUN" = true ]; then
        local expr
        for expr in "$@"; do
            printf '%b   [dry-run] sed -i %s %s%b\n' "$C_DIM" "'$expr'" "${file#"$REPO_ROOT"/}" "$C_RESET"
        done
        return 0
    fi
    local expr
    for expr in "$@"; do
        sed_inplace "$expr" "$file"
    done
}

# ============================================================================
# SLUG / IDENTIFIER DERIVATION
# ============================================================================

validate_slug() {
    local slug="$1" label="$2"
    if ! printf '%s' "$slug" | grep -Eq '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
        die "Invalid $label: '$slug'." \
            "Use lowercase letters, digits and hyphens only, e.g. 'acme-corp'." \
            "It must not start or end with a hyphen."
    fi
}

slug_to_display_name() {
    printf '%s' "$1" | sed 's/[-_]/ /g' |
        awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1'
}

slug_to_snake() { printf '%s' "$1" | tr '-' '_'; }

# my-project → sv_my_project_ . The `sv_` marker is the agency brand and is kept
# on purpose, matching the block namespace (studioval/) and the CSS prefix.
theme_prefix_from_slug() { printf 'sv_%s_' "$(slug_to_snake "$1")"; }

# Plugin identifier forms: my-plugin → my_plugin / My_Plugin / MY_PLUGIN / myPlugin / mp
PLUGIN_KEBAB="" PLUGIN_SNAKE="" PLUGIN_PASCAL="" PLUGIN_SCREAM="" PLUGIN_CAMEL="" PLUGIN_INITIALS="" PLUGIN_DISPLAY=""
plugin_compute_forms() {
    local slug="$1"
    PLUGIN_KEBAB="$slug"
    PLUGIN_SNAKE="$(slug_to_snake "$slug")"
    PLUGIN_PASCAL="$(printf '%s' "$slug" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1' OFS='_')"
    PLUGIN_SCREAM="$(printf '%s' "$PLUGIN_SNAKE" | tr '[:lower:]' '[:upper:]')"
    PLUGIN_CAMEL="$(printf '%s' "$slug" | awk -F'-' '{out=tolower($1); for(i=2;i<=NF;i++) out=out toupper(substr($i,1,1)) tolower(substr($i,2)); print out}')"
    PLUGIN_INITIALS="$(printf '%s' "$slug" | awk -F'-' '{for(i=1;i<=NF;i++) printf "%s", substr($i,1,1); print ""}')"
    # A one-letter CSS prefix (single-word slug) is too generic to be safe.
    if [ "${#PLUGIN_INITIALS}" -lt 2 ]; then
        PLUGIN_INITIALS="$(printf '%s' "$slug" | cut -c1-3)"
    fi
    PLUGIN_DISPLAY="$(slug_to_display_name "$slug")"
}

# ============================================================================
# FLAGS
# ============================================================================

usage() {
    cat <<'USAGE'
WordPress FSE Boilerplate — project setup

Usage: ./bin/setup.sh [OPTIONS]

Renames the theme and the plugin scaffold, substitutes every boilerplate
identifier, and repoints every config that hardcodes the old paths.

Options:
  --theme-dest=SLUG           Target theme folder name (required with --yes)
  --plugin-dest=SLUG          Target plugin slug, or 'skip' to leave it alone
  --theme-src=SLUG            Source theme folder (default: auto-detected)
  --theme=SLUG                Alias for --theme-src
  --theme-prefix=PREFIX       PHP function prefix (default: sv_<theme_dest>_)
  --github-user=USER          GitHub owner used in the Theme URI header
                              (default: valentin-grenier)

  --dry-run                   Print every action without performing any of them
  --yes, -y                   Non-interactive: take defaults, skip confirmation
  --force                     Run even when the placeholders look consumed

  --skip-plugins              Do not install the recommended wordpress.org plugins
  --skip-plugin-boilerplate   Leave the plugin scaffold untouched
  --skip-content              Do not create the homepage or activate the theme
  --skip-branches             Do not commit or create staging/development
  --help, -h                  Show this message

Examples:
  ./bin/setup.sh
  ./bin/setup.sh --dry-run --theme-dest=acme-corp
  ./bin/setup.sh --yes --theme-dest=acme-corp --plugin-dest=acme-core

Prerequisites (all validated before anything is modified):
  ddev (running), WP-CLI, composer, npm, node, git, PHP >= 8.2
USAGE
}

parse_flags() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) DRY_RUN=true ;;
            --yes | -y) ASSUME_YES=true ;;
            --force) FORCE=true ;;
            --skip-plugins) SKIP_PLUGINS=true ;;
            --skip-plugin-boilerplate) SKIP_PLUGIN_BOILERPLATE=true ;;
            --skip-branches) SKIP_BRANCHES=true ;;
            --skip-content) SKIP_CONTENT=true ;;
            --theme=* | --theme-src=*) THEME_SRC="${1#*=}" ;;
            --theme-dest=*) THEME_DEST="${1#*=}" ;;
            --theme-prefix=*) THEME_PREFIX="${1#*=}" ;;
            --plugin-dest=*) PLUGIN_DEST="${1#*=}" ;;
            --github-user=*) GITHUB_USER="${1#*=}" ;;
            --help | -h)
                usage
                exit 0
                ;;
            *)
                # Previously unknown flags were silently ignored, so a typo such as
                # --skip-git ran a full setup while the user believed otherwise.
                printf '%b❌ Unknown option: %s%b\n\n' "$C_RED" "$1" "$C_RESET" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

# ============================================================================
# PREFLIGHT — everything is checked before the first mutation
# ============================================================================

have() { command -v "$1" >/dev/null 2>&1; }

detect_wp_cli() {
    if have ddev && ddev exec true >/dev/null 2>&1; then
        WP="ddev wp"
        log_success "DDEV is running — using 'ddev wp'"
        return 0
    fi
    if have wp; then
        WP="wp"
        log_warning "DDEV not running — falling back to the host WP-CLI"
        return 0
    fi
    die "No usable WP-CLI found." \
        "Start the local environment:  ddev start" \
        "…or install WP-CLI globally:  https://wp-cli.org/#installing"
}

check_php_version() {
    local php_bin="" version=""
    if have php; then
        php_bin="php"
    elif have ddev && ddev exec true >/dev/null 2>&1; then
        php_bin="ddev_php"
    else
        log_warning "PHP not found on the host — skipping the version check"
        return 0
    fi

    if [ "$php_bin" = "ddev_php" ]; then
        version="$(ddev exec php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || true)"
    else
        version="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || true)"
    fi

    if [ -z "$version" ]; then
        log_warning "Could not determine the PHP version — skipping the check"
        return 0
    fi

    # Sort-based numeric comparison; no bc / awk float dependency.
    local lowest
    lowest="$(printf '%s\n%s\n' "$version" "$MIN_PHP_VERSION" | sort -t. -k1,1n -k2,2n | head -1)"
    if [ "$lowest" != "$MIN_PHP_VERSION" ] && [ "$version" != "$MIN_PHP_VERSION" ]; then
        die "PHP $version is below the required $MIN_PHP_VERSION." \
            "Set php_version: \"$MIN_PHP_VERSION\" (or newer) in .ddev/config.yaml, then: ddev restart"
    fi
    log_success "PHP $version (>= $MIN_PHP_VERSION)"
}

check_node_version() {
    have node || die "node not found." \
        "Install Node — the version in .nvmrc:  nvm install && nvm use"

    local required="" current=""
    if [ -f "$REPO_ROOT/.nvmrc" ]; then
        required="$(tr -d 'v \t\r\n' <"$REPO_ROOT/.nvmrc" 2>/dev/null || true)"
    fi
    current="$(node --version 2>/dev/null | tr -d 'v' | cut -d. -f1 || true)"

    if [ -n "$required" ] && [ -n "$current" ] && [ "${required%%.*}" != "$current" ]; then
        log_warning "Node v$current is active but .nvmrc asks for v$required — run 'nvm use'"
    else
        log_success "node $(node --version 2>/dev/null || echo '?')"
    fi
}

check_git() {
    have git || die "git not found." "Install git, then re-run this script."

    if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        if [ "$SKIP_BRANCHES" = true ]; then
            log_warning "Not a git repository — branch setup already disabled"
            return 0
        fi
        die "Not a git repository, so the setup cannot commit its result." \
            "Clone your project from the template instead of copying the files," \
            "…or re-run with --skip-branches to skip the commit and branches."
    fi

    if [ "$SKIP_BRANCHES" = false ]; then
        local name email
        name="$(git -C "$REPO_ROOT" config user.name 2>/dev/null || true)"
        email="$(git -C "$REPO_ROOT" config user.email 2>/dev/null || true)"
        if [ -z "$name" ] || [ -z "$email" ]; then
            die "git has no commit identity configured, so the final commit would fail." \
                "git config --global user.name  \"Your Name\"" \
                "git config --global user.email \"you@example.com\"" \
                "…or re-run with --skip-branches."
        fi
    fi
    log_success "git $(git --version 2>/dev/null | awk '{print $3}' || echo '?')"
}

preflight() {
    log_step "🔍 PREFLIGHT"

    [ -d "$THEMES_DIR" ] || die "No wp-content/themes/ directory at $THEMES_DIR." \
        "Run this script from the root of the project checkout."

    [ -f "$REPO_ROOT/wp-config.php" ] || die "wp-config.php not found in $REPO_ROOT." \
        "Start the local environment:  ddev start" \
        "…and run this script from the project root."

    [ -f "$REPO_ROOT/wp-includes/version.php" ] || die "WordPress core files are missing." \
        "Download them:  ddev wp core download"

    detect_wp_cli
    check_php_version
    check_node_version
    check_git

    have composer || die "composer not found." \
        "Install Composer: https://getcomposer.org/download/" \
        "It is required by 'composer ci', the gate this setup repoints."
    log_success "composer $(composer --version 2>/dev/null | awk '{print $3}' || echo '?')"

    have npm || die "npm not found." "Install Node.js (it ships npm), then re-run."
    log_success "npm $(npm --version 2>/dev/null || echo '?')"

    # Ordering note: this script does not run composer install, and the lint
    # configs it rewrites are only exercised later by `composer ci`.
    if [ ! -d "$REPO_ROOT/vendor" ]; then
        log_info "vendor/ is absent — run 'composer install' after this script to enable 'composer ci'"
    fi

    if ! $WP core is-installed >/dev/null 2>&1; then
        log_warning "WordPress is not installed in the database yet"
        log_detail "Content seeding and theme activation will be skipped."
        log_detail "Install it with: ddev wp core install --url=\$(ddev exec printenv DDEV_PRIMARY_URL) \\"
        log_detail "    --title='My Site' --admin_user=admin --admin_password=admin \\"
        log_detail "    --admin_email=admin@example.com --skip-email"
        SKIP_CONTENT=true
    else
        log_success "WordPress is installed in the database"
    fi
}

# ============================================================================
# STATE GUARD — idempotency
# ============================================================================

# The previous revision guarded on wp-content/themes/theme-fse/style.css, which
# stops existing the moment the rename succeeds. A second run therefore sailed
# straight past the guard and re-ran every mutation. Both "already renamed" and
# "placeholders already consumed" are now hard errors unless --force is given.
check_pristine_state() {
    log_step "🧪 STATE CHECK"

    local source_path="$THEMES_DIR/$THEME_SRC"

    if [ ! -d "$source_path" ]; then
        if [ "$FORCE" = true ]; then
            log_warning "Source theme '$THEME_SRC' is missing — continuing because of --force"
            return 0
        fi
        die "Source theme '$THEME_SRC' does not exist in wp-content/themes/." \
            "This usually means the setup already ran and the theme is renamed." \
            "Check:  ls wp-content/themes/" \
            "Point at the right folder:  ./bin/setup.sh --theme-src=<existing-slug>" \
            "…or override the guard entirely with --force."
    fi

    local style_css="$source_path/style.css"
    if [ -f "$style_css" ] && ! grep -q "^Text Domain: $PLACEHOLDER_THEME_DOMAIN" "$style_css"; then
        if [ "$FORCE" = true ]; then
            log_warning "Placeholders already consumed in style.css — continuing because of --force"
            return 0
        fi
        # Two very different situations produce a consumed placeholder. Telling
        # the user to "git checkout main" when their project is simply already
        # set up would be actively harmful advice.
        if [ ! -d "$THEMES_DIR/$PLACEHOLDER_THEME_SLUG" ]; then
            die "This project has already been set up — theme '$THEME_SRC' no longer carries the boilerplate placeholders." \
                "Running the setup twice would rename an already-renamed project." \
                "If you meant to rename it again, do it explicitly:" \
                "   ./bin/setup.sh --force --theme-src=$THEME_SRC --theme-dest=<new-slug>"
        fi
        die "This checkout is not a pristine boilerplate — '$PLACEHOLDER_THEME_DOMAIN' is already consumed." \
            "You are most likely on the 'demo' branch, which ships an installed example." \
            "Start from the pristine base:  git checkout main" \
            "…or override the guard with --force."
    fi

    log_success "Pristine boilerplate confirmed (placeholders intact)"
}

# ============================================================================
# INPUT RESOLUTION — every prompt happens here, before any mutation
# ============================================================================

interactive() { [ "$ASSUME_YES" = false ] && [ -t 0 ]; }

# ask VARNAME "question" "default"
ask() {
    local __var="$1" __question="$2" __default="$3" __reply=""
    if ! interactive; then
        printf -v "$__var" '%s' "$__default"
        log_detail "$__question → $__default (non-interactive)"
        return 0
    fi
    # `|| __reply=""` keeps EOF from killing the script under `set -e`.
    read -r -p "$(printf '%b?%b %s [%s]: ' "$C_BOLD" "$C_RESET" "$__question" "$__default")" __reply || __reply=""
    printf -v "$__var" '%s' "${__reply:-$__default}"
}

detect_source_theme() {
    [ -z "$THEME_SRC" ] || return 0

    # The placeholder wins when present: a real install also carries the bundled
    # twenty* themes, so "exactly one theme folder" is almost never true.
    if [ -d "$THEMES_DIR/$PLACEHOLDER_THEME_SLUG" ]; then
        THEME_SRC="$PLACEHOLDER_THEME_SLUG"
        log_info "Source theme: $THEME_SRC"
        return 0
    fi

    local candidates=() slug
    while IFS= read -r slug; do
        case "$slug" in
            twenty*) continue ;;
        esac
        candidates+=("$slug")
    done < <(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)

    if [ "${#candidates[@]}" -eq 1 ]; then
        THEME_SRC="${candidates[0]}"
        log_info "Auto-detected source theme: $THEME_SRC"
        return 0
    fi

    if [ "${#candidates[@]}" -eq 0 ]; then
        die "No candidate theme found in wp-content/themes/." \
            "Expected '$PLACEHOLDER_THEME_SLUG'. Check out the pristine 'main' branch," \
            "or name the folder explicitly:  ./bin/setup.sh --theme-src=<slug>"
    fi

    if ! interactive; then
        die "Several themes found and --theme-src was not given: ${candidates[*]}" \
            "Name the source explicitly:  ./bin/setup.sh --theme-src=<slug> --theme-dest=<slug>"
    fi

    log_info "Several themes found:"
    for slug in "${candidates[@]}"; do
        log_detail "– $slug"
    done
    ask THEME_SRC "Source theme to rename" "${candidates[0]}"
}

resolve_inputs() {
    log_step "📝 PROJECT IDENTITY"

    detect_source_theme

    # --theme-src used to be trusted blindly; a bad value degraded to a warning
    # and the run continued, eventually trying to activate a theme that was
    # never created.
    if [ ! -d "$THEMES_DIR/$THEME_SRC" ]; then
        die "Source theme '$THEME_SRC' does not exist in wp-content/themes/." \
            "Available: $(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | tr '\n' ' ')"
    fi

    if [ -z "$THEME_DEST" ]; then
        if ! interactive; then
            die "--theme-dest is required for a non-interactive run." \
                "Example:  ./bin/setup.sh --yes --theme-dest=acme-corp --plugin-dest=acme-core"
        fi
        ask THEME_DEST "Target theme folder name" "$THEME_SRC"
    fi
    validate_slug "$THEME_DEST" "theme slug"

    if [ "$THEME_DEST" != "$THEME_SRC" ] && [ -e "$THEMES_DIR/$THEME_DEST" ]; then
        die "wp-content/themes/$THEME_DEST already exists." \
            "Pick another slug, or remove the existing folder first."
    fi

    if [ -z "$THEME_PREFIX" ]; then
        THEME_PREFIX="$(theme_prefix_from_slug "$THEME_DEST")"
    fi
    if ! printf '%s' "$THEME_PREFIX" | grep -Eq '^[a-z][a-z0-9_]*_$'; then
        die "Invalid theme prefix: '$THEME_PREFIX'." \
            "Use lowercase letters, digits and underscores, ending with '_' (e.g. 'sv_acme_')."
    fi

    if [ "$SKIP_PLUGIN_BOILERPLATE" = false ] && [ -d "$PLUGINS_DIR/$PLACEHOLDER_PLUGIN_SLUG" ]; then
        if [ -z "$PLUGIN_DEST" ]; then
            ask PLUGIN_DEST "Target plugin slug ('skip' to leave it alone)" "$PLACEHOLDER_PLUGIN_SLUG"
        fi
        if [ "$PLUGIN_DEST" = "skip" ]; then
            SKIP_PLUGIN_BOILERPLATE=true
            PLUGIN_DEST=""
        else
            validate_slug "$PLUGIN_DEST" "plugin slug"
            if [ "$PLUGIN_DEST" != "$PLACEHOLDER_PLUGIN_SLUG" ] && [ -e "$PLUGINS_DIR/$PLUGIN_DEST" ]; then
                die "wp-content/plugins/$PLUGIN_DEST already exists." "Pick another slug."
            fi
        fi
    else
        SKIP_PLUGIN_BOILERPLATE=true
        PLUGIN_DEST=""
    fi
}

# ============================================================================
# PLAN + CONFIRM
# ============================================================================

show_plan() {
    local text_domain="$THEME_DEST"
    log_step "📋 PLAN"

    printf '  Theme\n'
    log_detail "folder        wp-content/themes/$THEME_SRC → wp-content/themes/$THEME_DEST"
    log_detail "display name  $(slug_to_display_name "$THEME_DEST")"
    log_detail "text domain   $PLACEHOLDER_THEME_DOMAIN → $text_domain"
    log_detail "php prefix    $PLACEHOLDER_THEME_PREFIX → $THEME_PREFIX"
    log_detail "theme uri     https://github.com/$GITHUB_USER/$THEME_DEST"

    if [ "$SKIP_PLUGIN_BOILERPLATE" = false ]; then
        plugin_compute_forms "$PLUGIN_DEST"
        printf '\n  Plugin\n'
        log_detail "folder        wp-content/plugins/$PLACEHOLDER_PLUGIN_SLUG → wp-content/plugins/$PLUGIN_KEBAB"
        log_detail "classes       Studioval_Plugin_Boilerplate_ → ${PLUGIN_PASCAL}_"
        log_detail "constants     STUDIOVAL_PLUGIN_BOILERPLATE_ → ${PLUGIN_SCREAM}_"
        log_detail "js global     studiovalPluginBoilerplate → $PLUGIN_CAMEL"
        log_detail "css prefix    svpb- → ${PLUGIN_INITIALS}-"
    else
        printf '\n  Plugin\n'
        log_detail "left untouched"
    fi

    printf '\n  Configs repointed at the renamed theme\n'
    local f
    for f in "${EXTERNAL_REFERENCE_FILES[@]}"; do
        log_detail "$f"
    done

    printf '\n  Optional steps\n'
    log_detail "recommended plugins   $([ "$SKIP_PLUGINS" = true ] && echo 'skipped' || echo 'install 13 from wordpress.org')"
    log_detail "theme activation      $([ "$SKIP_CONTENT" = true ] && echo 'skipped' || echo 'activate + seed homepage')"
    log_detail "git                   $([ "$SKIP_BRANCHES" = true ] && echo 'skipped' || echo 'commit + create staging/development')"
}

confirm_plan() {
    if [ "$DRY_RUN" = true ] || [ "$ASSUME_YES" = true ]; then
        return 0
    fi
    if [ ! -t 0 ]; then
        die "This run is non-interactive but --yes was not given." \
            "Re-run with --yes once you are happy with the plan above," \
            "or preview it first with --dry-run."
    fi
    printf '\n'
    local reply=""
    read -r -p "$(printf '%bProceed with the changes above? [y/N]: %b' "$C_BOLD" "$C_RESET")" reply || reply=""
    case "$reply" in
        [Yy] | [Yy][Ee][Ss]) ;;
        *) die "Cancelled — nothing was modified." "Preview the plan any time with:  ./bin/setup.sh --dry-run" ;;
    esac
}

# ============================================================================
# STEP — THEME
# ============================================================================

# Under --dry-run nothing is actually moved, and a resumed run may already have
# the folder renamed. Every later step asks for the path that exists right now,
# while the plan and the logs keep reporting the destination slug.
resolve_theme_path() {
    if [ -d "$THEMES_DIR/$THEME_DEST" ]; then
        printf '%s' "$THEMES_DIR/$THEME_DEST"
    else
        printf '%s' "$THEMES_DIR/$THEME_SRC"
    fi
}

resolve_plugin_path() {
    if [ -d "$PLUGINS_DIR/$PLUGIN_DEST" ]; then
        printf '%s' "$PLUGINS_DIR/$PLUGIN_DEST"
    else
        printf '%s' "$PLUGINS_DIR/$PLACEHOLDER_PLUGIN_SLUG"
    fi
}

rename_theme_folder() {
    if [ "$THEME_SRC" = "$THEME_DEST" ]; then
        log_info "Theme slug unchanged ($THEME_DEST) — no folder rename"
        return 0
    fi
    if [ -d "$THEMES_DIR/$THEME_DEST" ]; then
        log_info "wp-content/themes/$THEME_DEST already exists — rename already done"
        return 0
    fi
    run mv "$THEMES_DIR/$THEME_SRC" "$THEMES_DIR/$THEME_DEST"
    log_success "Theme folder renamed: $THEME_SRC → $THEME_DEST"
}

update_theme_header() {
    local theme_path="$1" style_css="$1/style.css"
    local display_name text_domain
    display_name="$(slug_to_display_name "$THEME_DEST")"
    text_domain="$THEME_DEST"

    if [ ! -f "$style_css" ]; then
        log_error "style.css not found at $style_css — theme header not updated"
        return 0
    fi

    apply_sed "$style_css" \
        "s|^Theme Name: .*|Theme Name: $display_name|" \
        "s|^Theme URI: .*|Theme URI: https://github.com/$GITHUB_USER/$THEME_DEST|" \
        "s|^Text Domain: .*|Text Domain: $text_domain|"
    log_success "style.css header updated ($display_name)"
}

# Replaces the PHP function/hook prefix across the theme. This was documented in
# CLAUDE.md as handled by the setup script but was never implemented, so every
# generated project shipped with the boilerplate prefix on all 95 call sites —
# and two client sites on one host collided on hook names.
update_theme_prefix() {
    local theme_path="$1"
    local files=() file
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$theme_path" -name '*.php' -type f \
        ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/vendor/*' -print0)

    if [ "${#files[@]}" -eq 0 ]; then
        log_warning "No theme PHP files found — prefix not substituted"
        return 0
    fi

    local touched=0
    for file in "${files[@]}"; do
        grep -q "$PLACEHOLDER_THEME_PREFIX" "$file" || continue
        apply_sed "$file" "s/${PLACEHOLDER_THEME_PREFIX}/${THEME_PREFIX}/g"
        touched=$((touched + 1))
    done
    log_success "PHP prefix substituted in $touched file(s): $PLACEHOLDER_THEME_PREFIX → $THEME_PREFIX"
}

update_theme_text_domain() {
    local theme_path="$1" text_domain="$2"
    local src="$PLACEHOLDER_THEME_DOMAIN"

    # 1) Quoted occurrences in theme PHP + JS sources.
    local file
    while IFS= read -r -d '' file; do
        grep -q "'$src'" "$file" || continue
        apply_sed "$file" "s/'$src'/'$text_domain'/g"
    done < <(find "$theme_path" \( -name '*.php' -o -name '*.js' \) -type f \
        ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/vendor/*' -print0)

    # 2) Pattern headers carry the namespace unquoted (Slug:/Categories:).
    if [ -d "$theme_path/patterns" ]; then
        local pattern
        while IFS= read -r -d '' pattern; do
            apply_sed "$pattern" "/^ \\* \\(Slug\\|Categories\\):/ s|$src|$text_domain|g"
        done < <(find "$theme_path/patterns" -name '*.php' -type f -print0)
    fi

    # 3) languages/: rename files, repoint the embedded domain, rebuild the .mo.
    local lang_dir="$theme_path/languages"
    if [ -d "$lang_dir" ]; then
        local f base
        for f in "$lang_dir/$src"*; do
            [ -e "$f" ] || continue
            base="$(basename "$f")"
            run mv "$f" "$lang_dir/${base/$src/$text_domain}"
        done
        local tf
        while IFS= read -r -d '' tf; do
            apply_sed "$tf" "s/$src/$text_domain/g"
        done < <(find "$lang_dir" -type f \( -name '*.pot' -o -name '*.po' -o -name '*.l10n.php' \) -print0)
        if have msgfmt; then
            local po
            for po in "$lang_dir"/*.po; do
                [ -e "$po" ] || continue
                run msgfmt "$po" -o "${po%.po}.mo" || log_warning "msgfmt failed on $(basename "$po")"
            done
        fi
    fi

    # 4) Display name in the block categories file.
    local block_categories="$theme_path/inc/block-categories.php"
    if [ -f "$block_categories" ]; then
        apply_sed "$block_categories" "s/'Theme Name'/'$(slug_to_display_name "$THEME_DEST")'/g"
    fi

    log_success "Text domain propagated: $src → $text_domain"
}

# ============================================================================
# STEP — EXTERNAL REFERENCES (the manifest)
# ============================================================================

rewrite_external_references() {
    local src="$1" dest="$2"

    if [ "$src" = "$dest" ]; then
        log_info "Theme slug unchanged — external references already correct"
        return 0
    fi

    local f path rewritten=0
    for f in "${EXTERNAL_REFERENCE_FILES[@]}"; do
        path="$REPO_ROOT/$f"
        if [ ! -f "$path" ]; then
            log_warning "Listed in the manifest but missing: $f"
            continue
        fi
        if ! grep -q "themes/$src" "$path"; then
            log_detail "no theme path to rewrite: $f"
            continue
        fi
        # Slash-free form on purpose: it matches every shape in the repo —
        # "themes/theme-fse/", "themes/theme-fse/_dev", "themes/theme-fse/dist/*".
        apply_sed "$path" "s|themes/$src|themes/$dest|g"
        log_success "Repointed $f"
        rewritten=$((rewritten + 1))
    done

    # smoke.sh also names the theme bare, in a WP-CLI call.
    local smoke="$REPO_ROOT/bin/smoke.sh"
    if [ -f "$smoke" ] && grep -q "theme status $src" "$smoke"; then
        apply_sed "$smoke" "s|theme status $src|theme status $dest|g"
        log_success "Repointed the WP-CLI theme check in bin/smoke.sh"
    fi

    log_info "$rewritten manifest file(s) repointed at wp-content/themes/$dest/"
}

# The template's deploy workflows refuse to deploy the boilerplate itself.
# Client projects must deploy, so the guard comes out.
#
# This used to be a `sed` range delete: if the opening comment ever drifted it
# silently removed nothing, and if the closing anchor drifted it removed
# everything to end of file. Each line is now deleted individually and the
# result is verified.
remove_template_deploy_guard() {
    local file="$1" name
    name="$(basename "$file")"

    if ! grep -q "if: github.repository != '$BOILERPLATE_REPO'" "$file"; then
        log_info "Deploy guard already absent in $name"
        return 0
    fi

    apply_sed "$file" \
        "/# The boilerplate repo is a template and must never deploy itself\./d" \
        "/# Client projects generated via bin\/setup\.sh live under a different/d" \
        "/# repository name, so the guard is true there and the deploy runs\./d" \
        "\|if: github\.repository != '$BOILERPLATE_REPO'|d"

    if [ "$DRY_RUN" = false ] && grep -q "github.repository != '$BOILERPLATE_REPO'" "$file"; then
        log_error "Failed to remove the deploy guard from $name — remove it by hand before deploying"
        return 0
    fi
    log_success "Removed the template deploy guard from $name"
}

update_workflow_files() {
    local wf
    for wf in deploy-staging deploy-production; do
        local path="$REPO_ROOT/.github/workflows/$wf.yml"
        if [ ! -f "$path" ]; then
            log_warning "$wf.yml not found — skipping"
            continue
        fi
        remove_template_deploy_guard "$path"
    done
}

# ============================================================================
# STEP — PLUGIN SCAFFOLD
# ============================================================================

plugin_substitute_in_file() {
    local file="$1"
    # Longest / most specific first so nothing is substituted twice.
    apply_sed "$file" \
        "s/STUDIOVAL_PLUGIN_BOILERPLATE/$PLUGIN_SCREAM/g" \
        "s/Studioval_Plugin_Boilerplate/$PLUGIN_PASCAL/g" \
        "s/studioval_plugin_boilerplate/$PLUGIN_SNAKE/g" \
        "s/studiovalPluginBoilerplate/$PLUGIN_CAMEL/g" \
        "s/studioval-plugin-boilerplate/$PLUGIN_KEBAB/g" \
        "s/svpb-/${PLUGIN_INITIALS}-/g" \
        "s/svpb_/${PLUGIN_INITIALS}_/g"
}

update_plugin_info() {
    local plugin_path="$1"
    local file count=0

    # vendor/ is excluded here too now: with Composer deps installed inside the
    # plugin, the previous walk would have rewritten third-party sources.
    while IFS= read -r -d '' file; do
        plugin_substitute_in_file "$file"
        count=$((count + 1))
    done < <(find "$plugin_path" \
        \( -name '*.php' -o -name '*.js' -o -name '*.json' -o -name '*.scss' \
        -o -name '.babelrc' -o -name '.eslintrc.json' -o -name '.stylelintrc.json' \) \
        -type f \
        ! -path '*/node_modules/*' \
        ! -path '*/dist/*' \
        ! -path '*/vendor/*' \
        -print0)

    local main_file="$plugin_path/$PLUGIN_KEBAB.php"
    if [ -f "$main_file" ]; then
        apply_sed "$main_file" "s|^ \\* Plugin Name:.*$| * Plugin Name:       Studio Val • $PLUGIN_DISPLAY|"
    fi

    log_success "Plugin identifiers substituted in $count file(s)"
}

update_plugin_lint_configs() {
    local plugin_slug="$1"
    local phpcs="$REPO_ROOT/phpcs.xml.dist"
    local phpstan="$REPO_ROOT/phpstan.neon.dist"

    if [ -f "$phpcs" ]; then
        apply_sed "$phpcs" \
            "s|wp-content/plugins/$PLACEHOLDER_PLUGIN_SLUG/|wp-content/plugins/$plugin_slug/|g" \
            "s|<element value=\"$PLACEHOLDER_PLUGIN_SLUG\"/>|<element value=\"$plugin_slug\"/>|"
        log_success "phpcs.xml.dist repointed at the renamed plugin"
    fi

    if [ -f "$phpstan" ]; then
        # Order matters: constants → main-file path → directory paths.
        apply_sed "$phpstan" \
            "s|STUDIOVAL_PLUGIN_BOILERPLATE|$PLUGIN_SCREAM|g" \
            "s|/$PLACEHOLDER_PLUGIN_SLUG/$PLACEHOLDER_PLUGIN_SLUG.php|/$plugin_slug/$plugin_slug.php|g" \
            "s|wp-content/plugins/$PLACEHOLDER_PLUGIN_SLUG/|wp-content/plugins/$plugin_slug/|g"
        log_success "phpstan.neon.dist repointed at the renamed plugin"
    fi
}

update_plugin_gitignore() {
    local plugin_slug="$1"
    local gitignore="$REPO_ROOT/.gitignore"
    [ -f "$gitignore" ] || return 0
    grep -q "wp-content/plugins/$PLACEHOLDER_PLUGIN_SLUG/" "$gitignore" || return 0
    apply_sed "$gitignore" \
        "s|wp-content/plugins/$PLACEHOLDER_PLUGIN_SLUG/|wp-content/plugins/$plugin_slug/|g"
    log_success ".gitignore whitelist repointed at the renamed plugin"
}

update_plugin_boilerplate() {
    local source_path="$PLUGINS_DIR/$PLACEHOLDER_PLUGIN_SLUG"
    local target_path="$PLUGINS_DIR/$PLUGIN_DEST"

    plugin_compute_forms "$PLUGIN_DEST"

    if [ "$PLUGIN_DEST" != "$PLACEHOLDER_PLUGIN_SLUG" ]; then
        if [ -d "$target_path" ]; then
            log_info "wp-content/plugins/$PLUGIN_DEST already exists — rename already done"
        else
            run mv "$source_path" "$target_path"
            run mv "$target_path/$PLACEHOLDER_PLUGIN_SLUG.php" "$target_path/$PLUGIN_DEST.php"
            log_success "Plugin folder + main file renamed: $PLACEHOLDER_PLUGIN_SLUG → $PLUGIN_DEST"
        fi
    else
        log_info "Plugin slug unchanged: $PLUGIN_DEST"
    fi

    update_plugin_info "$(resolve_plugin_path)"
    update_plugin_lint_configs "$PLUGIN_DEST"
    update_plugin_gitignore "$PLUGIN_DEST"
}

# ============================================================================
# STEP — OPTIONAL: WORDPRESS.ORG PLUGINS
# ============================================================================

DEV_PLUGINS=(query-monitor updraftplus admin-site-enhancements contact-form-7 contact-form-7-honeypot)
PROD_PLUGINS=(broken-link-checker seo-by-rank-math complianz-gdpr webp-converter-for-media simple-history plausible-analytics wp-mail-smtp better-wp-security)

install_recommended_plugins() {
    if [ "$SKIP_PLUGINS" = true ]; then
        log_info "Skipping recommended plugins (--skip-plugins)"
        return 0
    fi
    log_step "🔌 RECOMMENDED PLUGINS"

    local plugin installed=0 failed=0

    log_info "Development plugins (installed + activated)"
    for plugin in "${DEV_PLUGINS[@]}"; do
        if [ "$DRY_RUN" = true ]; then
            log_detail "[dry-run] $WP plugin install $plugin --activate"
            continue
        fi
        if $WP plugin is-installed "$plugin" >/dev/null 2>&1; then
            $WP plugin activate "$plugin" >/dev/null 2>&1 || true
            log_detail "$plugin — already installed"
            continue
        fi
        if $WP plugin install "$plugin" --activate >/dev/null 2>&1; then
            log_detail "$plugin — installed + activated"
            installed=$((installed + 1))
        else
            log_warning "$plugin — install failed (offline, or not on wordpress.org)"
            failed=$((failed + 1))
        fi
    done

    log_info "Production plugins (installed, not activated)"
    for plugin in "${PROD_PLUGINS[@]}"; do
        if [ "$DRY_RUN" = true ]; then
            log_detail "[dry-run] $WP plugin install $plugin"
            continue
        fi
        if $WP plugin is-installed "$plugin" >/dev/null 2>&1; then
            log_detail "$plugin — already installed"
            continue
        fi
        if $WP plugin install "$plugin" >/dev/null 2>&1; then
            log_detail "$plugin — installed"
            installed=$((installed + 1))
        else
            log_warning "$plugin — install failed (offline, or not on wordpress.org)"
            failed=$((failed + 1))
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_success "$installed plugin(s) installed, $failed failed"
        if [ "$failed" -gt 0 ]; then
            log_detail "Retry later with: $WP plugin install <slug>"
        fi
    fi
}

# ============================================================================
# STEP — OPTIONAL: THEME ACTIVATION + HOMEPAGE
# ============================================================================

activate_theme() {
    if [ "$SKIP_CONTENT" = true ]; then
        log_info "Skipping theme activation (--skip-content, or WordPress not installed)"
        return 0
    fi
    log_step "🎨 THEME ACTIVATION"

    if [ "$DRY_RUN" = true ]; then
        log_detail "[dry-run] $WP theme activate $THEME_DEST"
        return 0
    fi

    local active=""
    active="$($WP theme list --status=active --field=name 2>/dev/null || true)"
    if [ "$active" = "$THEME_DEST" ]; then
        log_info "Theme '$THEME_DEST' is already active"
        return 0
    fi

    if $WP theme activate "$THEME_DEST" >/dev/null 2>&1; then
        log_success "Theme '$THEME_DEST' activated"
    else
        log_error "Could not activate theme '$THEME_DEST'"
        log_detail "Activate it by hand: $WP theme activate $THEME_DEST"
        log_detail "…or from wp-admin → Appearance → Themes"
    fi
}

create_homepage() {
    if [ "$SKIP_CONTENT" = true ]; then
        log_info "Skipping homepage creation (--skip-content, or WordPress not installed)"
        return 0
    fi
    log_step "🏠 HOMEPAGE"

    if [ "$DRY_RUN" = true ]; then
        log_detail "[dry-run] create the 'Accueil' page and set it as the static front page"
        log_detail "[dry-run] delete the default 'Sample Page'"
        return 0
    fi

    local show_on_front page_on_front
    show_on_front="$($WP option get show_on_front 2>/dev/null || echo '')"
    page_on_front="$($WP option get page_on_front 2>/dev/null || echo '0')"

    if [ "$show_on_front" = "page" ] && [ "$page_on_front" != "0" ]; then
        log_info "A static front page is already configured — nothing to do"
        return 0
    fi

    local content
    content="$(
        cat <<'BLOCK_CONTENT'
<!-- wp:heading {"level":1} -->
<h1 class="wp-block-heading">Bienvenue sur votre nouveau site</h1>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Ce site a été créé avec le boilerplate WP FSE de Studio Val. Cette page est un point de départ : modifiez-la ou supprimez-la depuis <strong>Pages → Toutes les pages</strong> dans l'administration WordPress.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":2} -->
<h2 class="wp-block-heading">Par où commencer ?</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul class="wp-block-list"><!-- wp:list-item -->
<li>Éditez cette page depuis <strong>Pages → Accueil</strong></li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>Personnalisez l'en-tête et le pied de page dans l'<strong>Éditeur de site</strong></li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>Ajoutez vos couleurs et typographies dans <strong>theme.json</strong></li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>Créez vos premiers blocs natifs avec <code>npm run make-block</code></li>
<!-- /wp:list-item --></ul>
<!-- /wp:list -->
BLOCK_CONTENT
    )"

    local homepage_id=""
    homepage_id="$($WP post create \
        --post_type=page \
        --post_title='Accueil' \
        --post_status=publish \
        --post_content="$content" \
        --porcelain 2>/dev/null || true)"

    if [ -z "$homepage_id" ] || ! printf '%s' "$homepage_id" | grep -Eq '^[0-9]+$'; then
        log_error "Could not create the homepage"
        log_detail "Create it by hand in wp-admin → Pages → Add New, then set it as the front page."
        return 0
    fi
    log_success "Homepage created (ID: $homepage_id)"

    $WP option update show_on_front 'page' >/dev/null 2>&1 || log_warning "Could not set show_on_front"
    $WP option update page_on_front "$homepage_id" >/dev/null 2>&1 || log_warning "Could not set page_on_front"
    log_success "Static front page configured"

    local sample_id=""
    sample_id="$($WP post list --post_type=page --post_status=publish --title='Sample Page' --field=ID --format=ids 2>/dev/null | head -1 || true)"
    if [ -n "$sample_id" ]; then
        $WP post delete "$sample_id" --force >/dev/null 2>&1 || log_warning "Could not delete 'Sample Page'"
        log_success "Default 'Sample Page' removed"
    fi
}

# ============================================================================
# STEP — VERIFY
# ============================================================================

# Fails the run if any placeholder survived. This is what keeps the manifest
# honest: add a file that references the theme path, forget to list it above,
# and this check turns the omission into a loud failure instead of a project
# that only breaks on the first CI run.
verify_no_placeholders() {
    log_step "🔎 VERIFY"

    if [ "$DRY_RUN" = true ]; then
        log_info "Skipped under --dry-run (nothing was modified)"
        return 0
    fi

    local exclude_args=() ex
    for ex in "${VERIFY_EXCLUDES[@]}"; do
        exclude_args+=(--exclude-dir="$ex" --exclude="$ex")
    done

    local leaked=0 pattern label hits
    for pattern in "$PLACEHOLDER_THEME_DOMAIN" "$PLACEHOLDER_THEME_PREFIX" "$PLACEHOLDER_PLUGIN_SLUG"; do
        if [ "$pattern" = "$PLACEHOLDER_PLUGIN_SLUG" ] && [ "$SKIP_PLUGIN_BOILERPLATE" = true ]; then
            continue
        fi
        hits="$(grep -rIl "$pattern" "$REPO_ROOT" "${exclude_args[@]}" 2>/dev/null || true)"
        if [ -n "$hits" ]; then
            log_error "Placeholder '$pattern' still present in:"
            printf '%s\n' "$hits" | sed "s|$REPO_ROOT/|      |"
            leaked=$((leaked + 1))
        fi
    done

    # The theme slug needs a path-shaped search: "theme-fse" as a bare word also
    # appears in prose the rename must not touch.
    if [ "$THEME_SRC" != "$THEME_DEST" ]; then
        hits="$(grep -rIl "themes/$THEME_SRC" "$REPO_ROOT" "${exclude_args[@]}" 2>/dev/null || true)"
        if [ -n "$hits" ]; then
            log_error "Old theme path 'themes/$THEME_SRC' still referenced in:"
            printf '%s\n' "$hits" | sed "s|$REPO_ROOT/|      |"
            log_detail "Add the file(s) to EXTERNAL_REFERENCE_FILES in bin/setup.sh, then re-run."
            leaked=$((leaked + 1))
        fi
    fi

    if [ "$leaked" -eq 0 ]; then
        log_success "No boilerplate placeholder left outside docs/ and .claude/"
    fi

    # Informational: agent/team docs keep describing the boilerplate on purpose.
    local doc_hits
    doc_hits="$(grep -rIl "$PLACEHOLDER_THEME_SLUG" "$REPO_ROOT/.claude" "$REPO_ROOT/docs" 2>/dev/null | wc -l | tr -d ' ' || true)"
    if [ "${doc_hits:-0}" -gt 0 ]; then
        log_info "$doc_hits file(s) under .claude/ and docs/ still mention '$PLACEHOLDER_THEME_SLUG' (team docs — update at your own pace)"
    fi
}

# ============================================================================
# STEP — GIT
# ============================================================================

finalize_project_branches() {
    if [ "$SKIP_BRANCHES" = true ]; then
        log_info "Skipping commit + branches (--skip-branches)"
        return 0
    fi
    log_step "🌿 GIT"

    if [ "$DRY_RUN" = true ]; then
        log_detail "[dry-run] git add -A && git commit -m 'chore: Initial project setup from boilerplate'"
        log_detail "[dry-run] git branch staging && git branch development"
        return 0
    fi

    git -C "$REPO_ROOT" add -A
    if git -C "$REPO_ROOT" diff --cached --quiet; then
        log_info "Nothing to commit — the working tree is already clean"
    elif git -C "$REPO_ROOT" commit -q -m "chore: Initial project setup from boilerplate"; then
        log_success "Setup result committed"
    else
        log_error "git commit failed — commit the setup result by hand"
        return 0
    fi

    local b
    for b in staging development; do
        if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$b"; then
            log_info "Branch '$b' already exists"
        elif git -C "$REPO_ROOT" branch "$b"; then
            log_success "Created branch: $b"
        else
            log_error "Could not create branch '$b'"
        fi
    done

    local current
    current="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    log_info "On '$current' (+ staging, development). Nothing has been pushed."
    log_detail "Configure the FTP secrets BEFORE pushing 'staging' or 'main' — the deploy guard is now off."
}

# ============================================================================
# SUMMARY
# ============================================================================

site_url() {
    local url=""
    if have ddev && ddev exec true >/dev/null 2>&1; then
        url="$(ddev exec printenv DDEV_PRIMARY_URL 2>/dev/null | tr -d '\r\n' || true)"
    fi
    if [ -z "$url" ] && [ -f "$REPO_ROOT/.ddev/config.yaml" ]; then
        local name
        name="$(sed -n 's/^name: *//p' "$REPO_ROOT/.ddev/config.yaml" | head -1 | tr -d '"' || true)"
        [ -n "$name" ] && url="https://$name.ddev.site"
    fi
    printf '%s' "$url"
}

show_summary() {
    local end duration minutes seconds
    end="$(date +%s)"
    duration=$((end - SETUP_START_TIME))
    minutes=$((duration / 60))
    seconds=$((duration % 60))

    log_step "📊 SUMMARY"
    printf '  Duration:  %dm %ds\n' "$minutes" "$seconds"
    printf '  Succeeded: %d\n' "$SETUP_SUCCESS_COUNT"
    printf '  Warnings:  %d\n' "$SETUP_WARNINGS"
    printf '  Errors:    %d\n' "$SETUP_ERRORS"

    if [ "$DRY_RUN" = true ]; then
        printf '\n%b🔍 Dry run complete — nothing was modified.%b\n' "$C_CYAN" "$C_RESET"
        printf '   Re-run without --dry-run to apply the plan above.\n'
        return 0
    fi

    if [ -n "$LOG_FILE" ]; then
        printf '  Log:       %s\n' "$LOG_FILE"
    fi

    if [ "$SETUP_ERRORS" -gt 0 ]; then
        printf '\n%b⚠️  Setup finished with %d error(s) — review them above before continuing.%b\n' \
            "$C_YELLOW" "$SETUP_ERRORS" "$C_RESET"
    else
        printf '\n%b🎉 Setup complete.%b\n' "$C_GREEN" "$C_RESET"
    fi

    local url
    url="$(site_url)"
    printf '\n  Next steps:\n'
    printf '    1. composer install\n'
    printf '    2. cd wp-content/themes/%s/_dev && nvm use && npm install && npm run build\n' "$THEME_DEST"
    printf '    3. composer ci          # lint + stan + test, now pointing at the renamed theme\n'
    printf '    4. bin/smoke.sh         # end-to-end check\n'
    if [ -n "$url" ]; then
        printf '    5. %s/wp-admin\n' "$url"
    fi
    printf '\n  Still carrying the boilerplate name (rename at your own pace):\n'
    printf '    • .ddev/config.yaml  →  name: %s\n' "$(sed -n 's/^name: *//p' "$REPO_ROOT/.ddev/config.yaml" 2>/dev/null | head -1 || echo '?')"
    printf '    • .claude/ and docs/ team documentation\n'
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_flags "$@"

    SETUP_START_TIME="$(date +%s)"
    setup_logging

    printf '%b%s%b\n' "$C_BOLD" "WordPress FSE Boilerplate — setup" "$C_RESET"
    if [ "$DRY_RUN" = true ]; then
        printf '%b(dry run — nothing will be modified)%b\n' "$C_CYAN" "$C_RESET"
    fi

    preflight
    resolve_inputs
    check_pristine_state
    show_plan
    confirm_plan

    log_step "🎨 THEME"
    rename_theme_folder
    local theme_path
    theme_path="$(resolve_theme_path)"
    update_theme_header "$theme_path"
    update_theme_prefix "$theme_path"
    update_theme_text_domain "$theme_path" "$THEME_DEST"

    log_step "🔧 CONFIGURATION"
    rewrite_external_references "$THEME_SRC" "$THEME_DEST"
    # The theme text domain also lives in the phpcs allowlist.
    if [ -f "$REPO_ROOT/phpcs.xml.dist" ]; then
        apply_sed "$REPO_ROOT/phpcs.xml.dist" \
            "s|$PLACEHOLDER_THEME_DOMAIN|$THEME_DEST|g"
        log_success "phpcs.xml.dist text-domain allowlist updated"
    fi
    update_workflow_files

    if [ "$SKIP_PLUGIN_BOILERPLATE" = false ]; then
        log_step "🧩 PLUGIN SCAFFOLD"
        update_plugin_boilerplate
    else
        log_info "Plugin scaffold left untouched"
    fi

    install_recommended_plugins
    activate_theme
    create_homepage
    verify_no_placeholders
    finalize_project_branches
    show_summary

    [ "$SETUP_ERRORS" -eq 0 ]
}

main "$@"
