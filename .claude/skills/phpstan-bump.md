---
name: phpstan-bump
description: Raise the PHPStan analysis level by one, triage new errors (real bugs vs WP false positives), fix or suppress them, and commit. Invoke when the user asks to bump PHPStan or raise the analysis level.
---

# Bump PHPStan level skill

## Context

- **Current level**: 5 (set in `phpstan.neon.dist`).
- **Target**: 8 (north star — not enforced yet).
- Bump **one level at a time**. Never skip levels.

## Existing non-blocking phpcs warnings (~18)

These are pre-existing; do not treat them as regressions from a level bump:

- `file_get_contents` / `file_put_contents` / `wp_redirect` — phpcs suggests WP alternatives.
- Unused-param notes on hook callbacks with required WP signatures (`$post`, `$query`, etc.).
- Commented-out code in `dashboard.php`.

## Workflow

1. **Bump the level** — edit `phpstan.neon.dist`: increment `level` by 1.
2. **Run**: `composer stan`
3. **Triage each error**:
   - **Real bug** — fix the PHP code.
   - **WP false positive** — add `// @phpstan-ignore-line` with a brief comment:
     ```php
     $value = $attributes['my_attr'] ?? null; // @phpstan-ignore-line — block attribute typed as mixed by phpstan-wordpress
     ```
4. **Confirm green**: `composer ci` (lint + stan + test must all pass, 0 errors).
5. **Commit** using the `git-open-pr` skill conventions:
   ```
   chore: Tooling - Raised PHPStan to level <N>
   ```

## Stopping condition

Stop after one level per session unless explicitly asked to continue. Confirm with the user before opening a PR.
