#!/bin/bash

set -eAdd commentMore actions

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_NAME="$(basename "$0")"
SCRIPT_PATH="$CURRENT_DIR/$SCRIPT_NAME"

echo "Moving everything from $CURRENT_DIR to $PARENT_DIR..."

# Remove known conflicting files/directories in parent
for item in wp-content .git .github .gitignore .editorconfig README.md setup-plugins.sh; do
    TARGET="$PARENT_DIR/$item"
    if [ -e "$TARGET" ]; then
        echo "Removing existing $item..."
        rm -rf "$TARGET"
    fi
done

# Build a safe list of items to move (excluding script itself)
FILES_TO_MOVE=()
while IFS= read -r -d '' file; do
  [ "$file" = "$SCRIPT_PATH" ] && continue
  FILES_TO_MOVE+=("$file")
done < <(find "$CURRENT_DIR" -mindepth 1 -maxdepth 1 -print0)

# Move everything
for file in "${FILES_TO_MOVE[@]}"; do
  mv "$file" "$PARENT_DIR"
done

# Go to parent directory
cd "$PARENT_DIR"

# Delete the script itself
# rm -- "$SCRIPT_PATH"

# Remove the original folder
rmdir "$CURRENT_DIR" || echo "⚠️ Could not remove $CURRENT_DIR — not empty?"

echo "Done ✅"
