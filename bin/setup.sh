#!/bin/bash

# ========== CONFIG ==========
# Default: look one level up from the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ROOT="$(dirname "$REPO_DIR")"
REPO_WP_CONTENT="$REPO_DIR/wp-content"
TARGET_WP_CONTENT="$TARGET_ROOT/wp-content"

DRY_RUN=false

# ========== FLAGS ==========
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
  esac
done

# ========== VALIDATION ==========
echo "🔍 Looking for WordPress installation..."

if [ -f "$TARGET_ROOT/wp-load.php" ]; then
  echo "✅ WordPress root detected at: $TARGET_ROOT"
else
  echo "❌ wp-load.php not found in $TARGET_ROOT — are you in a WP install?"
  exit 1
fi

# ========== MOVE THEME ==========
THEME_SOURCE="$REPO_WP_CONTENT/themes/theme-fse"
THEME_TARGET="$TARGET_WP_CONTENT/themes"

if [ -d "$THEME_SOURCE" ]; then
  echo "📦 Moving theme-fse to $THEME_TARGET/..."
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would move $THEME_SOURCE → $THEME_TARGET/"
  else
    mv "$THEME_SOURCE" "$THEME_TARGET/"
    echo "✅ theme-fse moved"
  fi
else
  echo "⚠️ theme-fse not found, skipping"
fi

# ========== MOVE PLUGINS DIRECTORY CONTENT ==========
PLUGINS_SOURCE="$REPO_WP_CONTENT/plugins"
PLUGINS_TARGET="$TARGET_WP_CONTENT/plugins"

echo "📁 Preparing plugins directory at $PLUGINS_TARGET..."

if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN] Would ensure $PLUGINS_TARGET exists"
else
  mkdir -p "$PLUGINS_TARGET"
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