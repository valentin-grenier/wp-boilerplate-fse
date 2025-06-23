#!/bin/bash

# ========== CONFIG ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CALLER_DIR="$(pwd)"
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

# ========== SAFETY: Prevent running inside the repo ==========
if [[ "$CALLER_DIR" == "$REPO_DIR"* ]]; then
  echo "❌ Cannot run cleanup from inside the repository directory!"
  echo "   Please 'cd' to one level above before running this script."
  exit 1
fi

# ========== DRY RUN MODE ==========
if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN] Would delete: $REPO_DIR"
  exit 0
fi

# ========== CONFIRMATION ==========
echo "⚠️  You are about to permanently delete:"
echo "    $REPO_DIR"
echo
read -p "Are you sure? (y/n): " CONFIRMATION

if [ "$CONFIRMATION" != "y" ]; then
  echo "❌ Cleanup aborted."
  exit 1
fi

# ========== EXECUTION ==========
echo "🧹 Deleting $REPO_DIR..."
rm -rf "$REPO_DIR"
echo "✅ Boilerplate repo deleted."
