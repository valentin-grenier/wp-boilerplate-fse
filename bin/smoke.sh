#!/usr/bin/env bash
# bin/smoke.sh
#
# End-to-end smoke check for the WP FSE boilerplate. Verifies DDEV is up,
# the theme is activatable, the site responds, PHP gates pass, and the
# frontend build completes. Exits non-zero on the first failure.
#
# Usage:
#   bin/smoke.sh             # full check
#   bin/smoke.sh --fast      # skip the npm build step (minutes saved when iterating)
#   bin/smoke.sh --no-ddev   # skip DDEV-dependent checks (CI without containers)

set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 1

FAST=false
NO_DDEV=false
for arg in "$@"; do
    case "$arg" in
        --fast)    FAST=true ;;
        --no-ddev) NO_DDEV=true ;;
        -h|--help)
            sed -n '2,10p' "$0"
            exit 0
            ;;
    esac
done

passed=0
failed=0
skipped=0
log=()

pass() { log+=("  ✅ $1"); passed=$((passed + 1)); }
fail() { log+=("  ❌ $1"); failed=$((failed + 1)); }
skip() { log+=("  ⏭  $1 (skipped)"); skipped=$((skipped + 1)); }
run()  {
    local label="$1"
    shift
    if "$@" >/tmp/smoke-last.log 2>&1; then
        pass "$label"
        return 0
    else
        fail "$label"
        log+=("      → see /tmp/smoke-last.log")
        return 1
    fi
}

echo "────────────────────────────────────────────────────────────────"
echo "  WP FSE Boilerplate — smoke check"
echo "────────────────────────────────────────────────────────────────"

# 1. DDEV + WordPress
if [ "$NO_DDEV" = true ]; then
    skip "ddev wp db check"
    skip "ddev wp theme status theme-fse"
    skip "curl homepage"
else
    run "ddev wp db check"                ddev wp db check
    run "ddev wp theme status theme-fse"  ddev wp theme status theme-fse
    url="https://wp-boilerplate-fse.ddev.site"
    if curl -sfI "$url" -o /tmp/smoke-last.log; then
        pass "curl $url -> 2xx"
    else
        fail "curl $url -> not reachable"
    fi
fi

# 2. PHP gates
run "composer lint"  composer lint
run "composer stan"  composer stan
run "composer test"  composer test

# 3. Frontend
if [ "$FAST" = true ]; then
    skip "npm run lint:js"
    skip "npm run lint:css"
    skip "npm run build"
else
    (
        cd wp-content/themes/theme-fse/_dev || exit 1
        # Skip gracefully if deps aren't installed yet
        if [ ! -d node_modules ]; then
            echo "node_modules missing — run npm install in _dev/"
            exit 1
        fi
        npm run lint:js
    ) && pass "npm run lint:js" || fail "npm run lint:js"

    (
        cd wp-content/themes/theme-fse/_dev || exit 1
        npm run lint:css
    ) && pass "npm run lint:css" || fail "npm run lint:css"

    (
        cd wp-content/themes/theme-fse/_dev || exit 1
        npm run build
    ) && pass "npm run build" || fail "npm run build"
fi

# Summary
echo ""
printf '%s\n' "${log[@]}"
echo "────────────────────────────────────────────────────────────────"
printf "  %d passed, %d failed, %d skipped\n" "$passed" "$failed" "$skipped"
echo "────────────────────────────────────────────────────────────────"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
