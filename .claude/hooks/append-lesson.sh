#!/usr/bin/env bash
# .claude/hooks/append-lesson.sh
#
# PreCompact hook — before Claude compacts the conversation, capture
# a short summary entry in .claude/lessons.md so patterns that
# surfaced during the session aren't lost when context is trimmed.
#
# Claude Code invokes PreCompact with the compaction reason on stdin.

set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0

lessons=".claude/lessons.md"
[ -f "$lessons" ] || {
    printf '# Lessons learned\n\nRolling log of patterns surfaced during Claude sessions, appended automatically by the PreCompact hook.\n\n' > "$lessons"
}

reason=$(cat 2>/dev/null || true)
timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
branch=$(git branch --show-current 2>/dev/null || echo 'unknown')

{
    echo ""
    echo "## $timestamp — branch \`$branch\`"
    echo ""
    if [ -n "$reason" ]; then
        printf '%s\n' "$reason"
    else
        echo "_(no compaction reason provided)_"
    fi
} >> "$lessons"

exit 0
