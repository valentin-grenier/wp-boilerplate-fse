#!/bin/bash

# WordPress FSE Boilerplate Cleanup Script
# Safely removes the boilerplate directory after setup completion

set -e  # Exit on any error

# ========== FUNCTIONS ==========
error_exit() {
  echo "❌ Error: $1" >&2
  exit 1
}

log_step() {
  echo ""
  echo "=========================================="
  echo "$1"
  echo "=========================================="
}

# ========== CONFIG ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ROOT="$(dirname "$REPO_DIR")"

# ========== VALIDATION ==========
log_step "🔍 VALIDATING CLEANUP CONDITIONS"

# Check if we're in a boilerplate directory
if [[ ! "$REPO_DIR" == *"wp-boilerplate-fse"* ]]; then
  error_exit "This doesn't appear to be a wp-boilerplate-fse directory. Safety check failed."
fi

# Check if WordPress exists in target
if [ ! -f "$TARGET_ROOT/wp-config.php" ]; then
  error_exit "No WordPress installation found in $TARGET_ROOT. Cannot proceed safely."
fi

# Check if theme exists in WordPress (indicating successful setup)
THEME_EXISTS=false
if [ -d "$TARGET_ROOT/wp-content/themes" ]; then
  # Look for any theme that might have come from this boilerplate
  if find "$TARGET_ROOT/wp-content/themes" -name "style.css" -exec grep -l "FSE Boilerplate\|WP.*Boilerplate" {} \; | head -1 >/dev/null 2>&1; then
    THEME_EXISTS=true
  fi
fi

if [ "$THEME_EXISTS" = false ]; then
  echo "⚠️  Warning: No boilerplate theme found in WordPress installation."
  echo "   This might indicate the setup wasn't completed successfully."
  echo ""
  read -p "   Continue with cleanup anyway? (y/n): " force_cleanup
  if [[ ! "$force_cleanup" =~ ^[Yy]$ ]]; then
    echo "   ⏹️  Cleanup cancelled"
    exit 0
  fi
fi

echo "✅ Validation passed"
echo "   📁 Boilerplate directory: $REPO_DIR"
echo "   🏠 WordPress directory: $TARGET_ROOT"

# ========== CLEANUP EXECUTION ==========
log_step "🧹 EXECUTING CLEANUP"

echo "⚠️  This will permanently delete the boilerplate directory:"
echo "   📁 $REPO_DIR"
echo ""
echo "   This action cannot be undone!"
echo ""

read -p "   🗑️  Are you sure you want to proceed? (y/n): " confirm_cleanup
echo ""

if [[ "$confirm_cleanup" =~ ^[Yy]$ ]]; then
  echo "🧹 Proceeding with cleanup..."
  
  # Change to parent directory to avoid issues
  cd "$TARGET_ROOT"
  
  # Remove the boilerplate directory
  if rm -rf "$REPO_DIR" 2>/dev/null; then
    echo "✅ Boilerplate directory removed successfully"
    
    # Remove this cleanup script if it was copied to target
    if [ -f "$TARGET_ROOT/cleanup.sh" ] && [ "$(realpath "$TARGET_ROOT/cleanup.sh")" != "$(realpath "$0")" ]; then
      rm -f "$TARGET_ROOT/cleanup.sh" 2>/dev/null
      echo "✅ Cleanup script removed from WordPress directory"
    fi
    
    echo ""
    echo "🎉 Cleanup completed successfully!"
    echo "   Your WordPress installation is ready for development."
    echo ""
  else
    error_exit "Failed to remove boilerplate directory. Check permissions."
  fi
else
  echo "   ⏹️  Cleanup cancelled"
  echo "   💡 You can run this script again anytime to clean up:"
  echo "      $0"
fi

echo "=========================================="
echo "🏁 CLEANUP FINISHED"
echo "=========================================="
