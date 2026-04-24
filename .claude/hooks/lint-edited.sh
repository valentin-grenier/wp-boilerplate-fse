#!/usr/bin/env bash
# .claude/hooks/lint-edited.sh
#
# PostToolUse hook — after Claude Edits or Writes a file, run the
# appropriate linter/formatter on it. Non-blocking: the hook never
# fails even if the linter finds issues; it just surfaces the output
# so Claude sees it in the next tool result context.
#
# Matched tools: Edit, Write.

set -u

# Read the hook payload from stdin (Claude Code sends JSON).
payload=$(cat)

# Extract the file path. jq is the standard tool; fall back to python3.
if command -v jq >/dev/null 2>&1; then
    file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
else
    file=$(printf '%s' "$payload" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)
fi

[ -z "$file" ] && exit 0
[ ! -f "$file" ] && exit 0

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0

case "$file" in
    *.php)
        if [ -x vendor/bin/phpcs ]; then
            vendor/bin/phpcs "$file" 2>&1 | tail -20 || true
        fi
        ;;
    *.js|*.scss|*.md|*.json)
        prettier=wp-content/themes/theme-fse/_dev/node_modules/.bin/prettier
        if [ -x "$prettier" ]; then
            "$prettier" --write "$file" 2>&1 | tail -5 || true
        fi
        ;;
esac

exit 0
