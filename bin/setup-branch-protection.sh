#!/usr/bin/env bash
# bin/setup-branch-protection.sh
#
# Applies branch protection rules to `main` and the repository merge settings
# via the GitHub REST API using the `gh` CLI. Idempotent — safe to re-run.
#
# What it enforces on main:
#   - Require a passing CI run (ci.yml jobs: 'PHP (lint + stan + test)' + 'Frontend (lint + build)')
#     plus the 'Checklist complete' job from pr-checklist.yml.
#   - Require at least 1 review from a CODEOWNER.
#   - Dismiss stale approvals when new commits are pushed.
#   - Block force-pushes.
#   - Block branch deletion.
#   - Apply to admins too (no accidental bypass).
#
# What it sets on the repository:
#   - Merge commits only: squash and rebase merging are disabled.
#
# Prerequisites:
#   - `gh auth login` completed with a token that has `repo` scope.
#   - The CI job names above must match .github/workflows/ci.yml (update here if you rename them).
#
# Usage:
#   bin/setup-branch-protection.sh                 # applies to 'main' on the current remote
#   bin/setup-branch-protection.sh --branch=staging  # override target branch
#   bin/setup-branch-protection.sh --dry-run       # print what would be sent without calling the API

set -euo pipefail

BRANCH="main"
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --branch=*) BRANCH="${arg#*=}" ;;
        --dry-run)  DRY_RUN=true ;;
        -h|--help)
            sed -n '2,27p' "$0"
            exit 0
            ;;
        *)
            echo "Unknown arg: $arg" >&2
            exit 2
            ;;
    esac
done

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: gh CLI is not installed. See https://cli.github.com/" >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh is not authenticated. Run 'gh auth login' first." >&2
    exit 1
fi

# Discover the owner/repo from the current directory's git remote.
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [ -z "$REPO" ]; then
    echo "Error: couldn't detect owner/repo via gh. Run this script inside a cloned repo with an origin remote." >&2
    exit 1
fi

echo "Applying branch protection to $REPO:$BRANCH ..."

read -r -d '' PAYLOAD <<'JSON' || true
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "PHP (lint + stan + test)",
      "Frontend (lint + build)",
      "Checklist complete"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

if [ "$DRY_RUN" = true ]; then
    echo "---- Payload (dry-run) ----"
    printf '%s\n' "$PAYLOAD"
    echo "---- Would PUT to /repos/$REPO/branches/$BRANCH/protection"
    echo "---- Would PATCH /repos/$REPO with allow_merge_commit=true allow_squash_merge=false allow_rebase_merge=false"
    exit 0
fi

# PUT the protection rules.
printf '%s' "$PAYLOAD" | gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO/branches/$BRANCH/protection" \
    --input -

echo "✅ Branch protection applied to $REPO:$BRANCH"

gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO" \
    -F allow_merge_commit=true \
    -F allow_squash_merge=false \
    -F allow_rebase_merge=false \
    >/dev/null

echo "✅ Merge commits only on $REPO"
echo ""
echo "Verify at: https://github.com/$REPO/settings/branches"
echo "       and https://github.com/$REPO/settings (Pull Requests section)"
