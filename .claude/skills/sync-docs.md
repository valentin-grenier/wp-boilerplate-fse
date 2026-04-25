---
name: sync-docs
description: Invoke automatically when the conversation adds or modifies Claude Code automation — hooks or permissions in .claude/settings.json, rules under .claude/rules/, agents under .claude/agents/, skills under .claude/skills/, slash commands under .claude/commands/, MCP servers in .mcp.json, or the team docs themselves (.claude/CLAUDE.md, ARCHITECTURE.md, BLOCKS.md, CONVENTIONS.md). Audits the team docs against the live state of .claude/ and proposes updates. Does not auto-apply edits — reports drift and proposes them for user approval.
---

# Sync docs skill

Purpose: catch drift between `.claude/` team docs and what actually exists when Claude-logic changes ship.

## When to invoke

Trigger this skill whenever the current turn adds, removes, or modifies any of:

- `.claude/settings.json` — hooks, permissions, env, models.
- `.claude/rules/**`
- `.claude/agents/**`
- `.claude/skills/**`
- `.claude/commands/**`
- `.claude/CLAUDE.md`, `ARCHITECTURE.md`, `BLOCKS.md`, `CONVENTIONS.md`
- `.mcp.json`
- Scripts under `.claude/hooks/` or `bin/` that are wired into Claude hooks.

If the current turn only edits theme code (`wp-content/themes/theme-fse/**`), do **not** invoke this skill.

## Procedure

1. **Read each team doc** under `.claude/`: CLAUDE.md, ARCHITECTURE.md, CONVENTIONS.md, BLOCKS.md, IMPLEMENTATION.md.
2. **Enumerate assertions each doc makes about Claude logic**, e.g.:
   - "5 hook types configured"
   - "rules/ contains security, i18n, blocks"
   - "one sub-agent: wp-reviewer"
   - ".mcp.json has Notion"
3. **Check the actual state**:
   - `jq '.hooks // {} | keys' .claude/settings.json` — list configured hook types.
   - `ls .claude/rules/` — list rule files.
   - `ls .claude/agents/` — list agents.
   - `ls .claude/skills/` — list skills.
   - `ls .claude/commands/` — list commands.
   - `jq '.mcpServers // {} | keys' .mcp.json 2>/dev/null` — list MCP servers.
4. **Diff claims against reality**. Produce a drift checklist.
5. **Propose edits, do not apply them**. For each drift, output a one-line fix proposal the user can approve.

## Output format

```
## Docs sync drift report

✅ In sync
- <file>: <assertion>

🔧 Drift
- <file>:<section> — claims <X>, actual <Y>
  proposed edit: <short patch description>

📝 Missing mention
- <thing in .claude/ not described in any doc>
  proposed edit: add a line to <file> under <section>
```

End with a one-line summary: `<N> drift items — approve to apply, or /ignore to dismiss.`

## Principles

- **Never silently edit.** Always surface the drift and ask.
- **Minimize the diff.** Propose the smallest change that restores sync.
- **Prefer updating the doc, not the code.** The code is the source of truth; docs describe the code, not vice-versa.
- **Respect the tracker.** `.claude/IMPLEMENTATION.md` is a narrative; only touch it for genuine drift, not historical context that's still accurate.
