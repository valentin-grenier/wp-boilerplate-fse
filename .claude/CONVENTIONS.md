# Conventions

Repository-wide **Git workflow** and **tooling** reference.

> Naming (text-domain, prefixes, namespaces), security, i18n, a11y and SCSS/component
> conventions are the auto-loaded rules in [`rules/`](rules/). Block authoring lives in
> [`../docs/blocks.md`](../docs/blocks.md). This file holds only what those don't.

## Git

**Semantic Commits.**

**Pattern:**

```text
<type>: <Scope> - <Subject>
```

- **`<type>`** — lowercase, required. One of the types listed below.
- **`<Scope>`** — capitalized, optional. The block, template, component, or area affected
  (e.g., `Single`, `Header`, `FAQ`, `README`, `Template`). Omit when the change is global.
- **`<Subject>`** — capitalized, required. Past tense (preterit) verb + brief description.

Examples:

- `feat: Single - Added breadcrumb block`
- `fix: Single - Resolved PHP notice in header block`
- `docs: README - Updated setup instructions`
- `style: FAQ - Edited toggle icon size`
- `refactor: Template - Renamed block template file for clarity`

Allowed types:

- `feat` — new feature for the user (not a new feature for a build script).
- `fix` — bug fix for the user (not a fix to a build script).
- `docs` — changes to documentation.
- `style` — formatting, missing semicolons, etc.; no production code change.
- `refactor` — refactoring production code (e.g., renaming a variable).
- `perf` — performance improvement; no functional change.
- `test` — adding missing tests or refactoring tests; no production code change.
- `build` — changes to the build system or external dependencies (Webpack, Composer, npm).
- `ci` — changes to CI configuration (`.github/workflows/**`, `dependabot.yml`).
- `chore` — updating tooling, dev tasks, or anything else that doesn't fit above; no production code change.

The flow below applies to **generated client projects** (in this template repo, `main` is the pristine base and `demo` the installed example — neither deploys).

**Branch flow:** `feature/<ticket>-<slug>` → `development` → `staging` → `main`. Never push directly
to `main` or `staging`.

⚠️ **Branch protection on `main` is not automatically active.** Run `bin/setup-branch-protection.sh` once locally (requires `gh auth login`) to enforce the CI gate and CODEOWNER review.

## PR checklist

See [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md). The current template
covers PR type, conventions, asset compilation, escaping, security guards, and docs.

✅ **CI runs on every PR.** `ci.yml` gates PHP lint/stan/test + Node lint/build.

## PHP & tooling

**PHP 8.2+** — `composer.json` requires `>=8.2` and pins `config.platform.php`; `style.css`
declares `Requires PHP: 8.2`. Short array syntax `[]` only (enforced by phpcs).

Config files live at the repo root as `<tool>.<ext>.dist` (the non-`.dist` versions are gitignored so local overrides never leak).

| Tool      | Purpose                                                        | Config file                                 | Run with                                                               |
| --------- | -------------------------------------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------- |
| `phpcs`   | Style + known-unsafe-pattern linter (WordPress-Extra ruleset). | [`phpcs.xml.dist`](../phpcs.xml.dist)       | `composer lint` (report) / `composer lint:fix` (auto-fix via `phpcbf`) |
| `phpstan` | Static analyzer — finds logic bugs without running the code.   | [`phpstan.neon.dist`](../phpstan.neon.dist) | `composer stan`                                                        |
| `phpunit` | Test runner. Picks up `tests/**Test.php`.                      | [`phpunit.xml.dist`](../phpunit.xml.dist)   | `composer test`                                                        |

**What "phpcs" catches:** indentation, docblocks, unescaped `echo`, missing nonces, text-domain
mismatches, direct SQL without `$wpdb->prepare`, `array()` instead of `[]`, etc. WordPress-Extra is
the broader of WP's two official rulesets — stricter than plain WordPress, looser than VIP.

**What "phpstan" catches:** calls to undefined functions, wrong argument types, paths that should
return a value but don't, unreachable code. Level 5 is the sweet spot for WP code. The
`szepeviktor/phpstan-wordpress` extension teaches phpstan the WP API (`add_action`,
`wp_kses_post`, `$wpdb`, `register_block_type`…) — without it, every WP call would be flagged as
"unknown function".

**What "phpunit" does:** runs test classes that extend `PHPUnit\Framework\TestCase`. No tests
exist yet; the config is pre-wired so `composer test` exits 0 today and picks up new files
dropped in `tests/` later.

**`composer ci`** runs all three (`lint` → `stan` → `test`) as one gate for CI and local pre-push.

**Front-end (run from `_dev/`):** `npm run lint:js` (ESLint, `@wordpress/eslint-plugin`),
`npm run lint:css` (Stylelint, `@wordpress/stylelint-config/scss`), `npm run format` (Prettier),
`npm run lint` (js + css together).
