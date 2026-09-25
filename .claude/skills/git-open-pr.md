---
name: git-open-pr
description: Runs the full ship workflow — build (if needed), commit, push, open PR with the project template. Invoke whenever the user asks to commit, push, create a PR, or "push this". Never merges.
---

# git-open-pr

Full ship workflow. Execute every step in order. Never skip. Never merge.

## Step 1 — Assess the diff

```bash
git status --short
git diff --stat HEAD
```

Note which areas changed (PHP, SCSS, JS, docs, config) — needed for the commit message and to decide whether a build is required.

## Step 2 — Build (only if SCSS or JS changed)

If any file under `_dev/scss/`, `_dev/js/`, or `_dev/blocks/` was modified:

```bash
cd wp-content/themes/theme-fse/_dev && npm run build
```

Build must exit 0. If it fails, stop and report the error — do not commit.

## Step 3 — Stage and commit

Stage only the relevant files. Never `git add -A` blindly when unrelated files are dirty.

**Commit message format** (full rules in `CONVENTIONS.md#git`):

```
<type>: <Scope> - <Subject>
```

- `<type>` — lowercase: `feat` · `fix` · `docs` · `style` · `refactor` · `perf` · `test` · `build` · `ci` · `chore`
- `<Scope>` — capitalized, optional. Block, template, or area affected. Omit for global changes.
- `<Subject>` — capitalized, preterit. Brief description.

Always use a HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
type: Scope - Subject
EOF
)"
```

## Step 4 — Push

```bash
git push -u origin <branch>
```

If the current branch is `main` or `staging`, stop and ask the user to create a feature branch first.

## Step 5 — Open PR

Read `.github/PULL_REQUEST_TEMPLATE.md`, then fill every section. The body must be in **English**.

- **Type of Change**: tick the boxes that match the diff.
- **Verification**: only commands you actually ran, with their result. No claim you did not see.
- **Manual testing**: numbered steps for what you could not check yourself (editor, browser, rendering, real data), each one action → expected result. **Never tick them**, nor the secrets item: the reviewer does, and `pr-checklist.yml` blocks the merge until they are all ticked.

```bash
gh pr create --title "<commit-title>" --body "$(cat <<'EOF'
## Description

<what changed and why>

## Related Issue

Closes #

## Type of Change

- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] ♻️ Refactor
- [ ] 🎨 Style / UI update
- [ ] 📦 Build / dependency update
- [ ] 📝 Documentation
- [ ] 🔒 Security fix
- [ ] 🔧 Configuration / chore

## Verification

<commands run and their result, e.g. `composer ci` → green>

## Manual testing

1. [ ] <action> → <expected result>

- [ ] No secrets or credentials in the diff

## Screenshots

<N/A or before/after if UI changed>

## Additional Notes

<anything reviewers should know, or remove section>
EOF
)"
```

## Step 6 — Report

Return the PR URL. Stop. Do not merge, approve, or request reviews.

## Guardrails

- Never force-push.
- Never rewrite history on `main`, `staging`, or `development`.
- Never push directly to `main` or `staging`.
- Never merge a PR.
- Never commit `wp-config*.php`, `.env`, or anything under `vendor/`, `node_modules/`, `dist/`.
