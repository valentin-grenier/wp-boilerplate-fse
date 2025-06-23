#!/bin/bash

# ========== CONFIG ==========
# Default: look one level up from the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ROOT="$(dirname "$REPO_DIR")"
REPO_WP_CONTENT="$REPO_DIR/wp-content"
TARGET_WP_CONTENT="$TARGET_ROOT/wp-content"
WP_PATH="$TARGET_ROOT"

DRY_RUN=false
SKUP_PLUGINS=false
THEME_SLUG=""

# ========== FLAGS ==========
for arg in "$@"; do
  case $arg in
    --dry-run)       DRY_RUN=true;        shift ;;
    --skip-plugins)  SKIP_PLUGINS=true;   shift ;;
    --theme=*)       THEME_SLUG="${arg#*=}"; shift ;;
    *)               # ignore other flags
                     ;;
  esac
done

# ========== ENV DETECTION & WP-CLI CHECK ==========
if [[ "$(uname -s)" == *"MINGW"* || "$(uname -s)" == *"NT"* ]]; then
  WP="cmd //c wp"
else
  WP="wp"
fi


if ! command -v $WP &> /dev/null; then
  echo "❌ WP-CLI not found in this shell."
  echo "👉 Tip: Run from Local’s Site Shell or install WP-CLI globally."
  exit 1
fi

# ========== VALIDATION ==========
echo "🔍 Looking for WordPress installation..."
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "❌ wp-config.php not found in $WP_PATH — check your WP_PATH."
  exit 1
fi

# -------- THEME AUTO-DETECT & RENAME --------

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
  echo "⚠️  No theme folder found in $REPO_WP_CONTENT/themes/"
  exit 1
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
if [ -z "$THEME_DEST" ]; then
  read -p "Enter target theme folder name (default: $THEME_SRC): " input_dest
  THEME_DEST="${input_dest:-$THEME_SRC}"
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
else
  echo "⚠️  Source theme '$THEME_SRC' not found — skipping"
fi



# ========== MOVE PLUGINS DIRECTORY CONTENT ==========
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
echo "📁 Moving root files to $TARGET_ROOT..."

FILES_TO_MOVE=(
  ".git"
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
