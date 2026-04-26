---
name: open-pr
description: Commit, push, and open a GitHub PR on request. Follow semantic commit format and the PULL_REQUEST_TEMPLATE.md. Invoke whenever the user asks to commit, push, create a PR, or "push this".
---

# Open PR skill

## When to invoke

- User asks to commit, push, or open a PR.
- User says "push this", "make a PR", or "commit and push".

## Workflow

`gh` CLI is installed and authenticated via SSH. When asked to commit, push, and open a PR, do all three without asking for confirmation.

### Commit format

Full rules in `.claude/CONVENTIONS.md#git`. Pattern:

```
<type>: <Scope> - <Subject>
```

- `<type>` — lowercase, required. One of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
- `<Scope>` — capitalized, optional. The block, template, or area affected. Omit for global changes.
- `<Subject>` — capitalized, preterit (past tense). Brief description.

Examples:

- `feat: Single - Added breadcrumb block`
- `fix: Header - Resolved PHP notice in navigation block`
- `chore: CI - Updated workflow trigger conditions`

### PR body

Use `gh pr create` with an **English** body following `.github/PULL_REQUEST_TEMPLATE.md`. Fill every section: Description, Related Issue, Type of Change checkboxes, and the full Checklist.

### Guardrails

- **Never force-push** to any branch.
- **Never rewrite history** (`git rebase -i`, `git reset --hard`, `git commit --amend`) on `main`, `staging`, or `development`.
- **Never push directly** to `main` or `staging` — always use a feature branch and PR.
- **Never merge a PR** — the user is the sole reviewer and merger. Stop after `gh pr create` and report the PR URL.
