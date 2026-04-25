---
description: Run the project's end-to-end smoke check (DB, theme, lint, stan, build).
---

Run `bin/smoke.sh` and report the result. The script validates:

- DDEV is up and WordPress responds.
- The theme is installed and activatable (`ddev wp theme status theme-fse`).
- `composer ci` passes (lint + stan + test).
- The frontend build completes cleanly (`npm run build` inside `_dev/`).
- Homepage returns HTTP 200.

If any step fails, surface the failure with enough context for the user to fix it. Don't try to fix underlying issues automatically unless the user asks.
