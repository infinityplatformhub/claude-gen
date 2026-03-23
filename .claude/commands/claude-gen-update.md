---
name: claude-gen-update
description: Update claude-gen framework to latest version.
             Downloads latest from GitHub, patches missing features, preserves project config.
---

## Update Framework

Pull the latest claude-gen framework and apply updates to this project.

### Step 1 — Download latest

```bash
rm -rf /tmp/claude-gen-update
git clone --depth 1 --quiet https://github.com/infinityplatformhub/claude-gen.git /tmp/claude-gen-update
```

If clone fails → report error and stop.

### Step 2 — Backup current framework files

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p .claude-backup/$TIMESTAMP
cp -r .claude/commands/ .claude-backup/$TIMESTAMP/commands/ 2>/dev/null
cp -r .claude/agents/ .claude-backup/$TIMESTAMP/agents/ 2>/dev/null
cp -r .claude/rules/ .claude-backup/$TIMESTAMP/rules/ 2>/dev/null
```

### Step 3 — Update framework files

```bash
cp /tmp/claude-gen-update/.claude/commands/*.md .claude/commands/
cp /tmp/claude-gen-update/.claude/agents/*.md .claude/agents/
cp -r /tmp/claude-gen-update/skills-library/. .claude/skills/_library/
mkdir -p .claude/bootstrap
cp -r /tmp/claude-gen-update/bootstrap/. .claude/bootstrap/
```

### Step 4 — Patch TODO.md

If `TODO.md` exists but missing `## Roadmap` section:

```bash
if [ -f TODO.md ] && ! grep -q "## Roadmap" TODO.md; then
  printf "\n---\n\n## Roadmap\n\n> No task ID yet — move to backlog sections above when ready to execute.\n\n_Empty_\n\n---\n\n## Ideas\n\n> Captured for future consideration. Not committed to.\n\n_Empty_\n" >> TODO.md
fi
```

### Step 5 — Patch CLAUDE.md

Read `CLAUDE.md` and fix these issues if found (do NOT use sed — read the file, edit intelligently):

1. **"/init" block message** — if the file says "Do NOT run `/init`", change to:
   `This file is managed by claude-gen framework. Use /claude-gen-init to re-initialize, /claude-gen-update to update.`

2. **Old doc rules** — if "Never create docs, reports, or analysis files" exists, change to:
   - `Never generate throwaway files (debug-result.md, benchmark.md, etc.) — report verbally`
   - `Do update existing docs when changes affect them`

3. **Missing pre-commit item** — if pre-commit checklist exists but lacks "No duplicate routes or components", add it

If nothing needs fixing → skip. Only edit what needs fixing. Do NOT rewrite or restructure CLAUDE.md.

### Step 6 — Review .claude/rules/ for stale content

Read each file in `.claude/rules/`. Look for:
- Stale comments that contradict current project state (e.g., "no tests configured" when tests exist)
- Outdated references to old paths or tools
- Placeholder text that was never filled in (e.g., "_Add during project init_")

For each issue found:
- Fix it directly (small edit, not rewrite)
- Report what was fixed

Do NOT delete or restructure rules files. Do NOT touch custom rules content.

### Step 7 — Patch .gitignore

Ensure these entries exist (add each one only if missing):

```bash
for entry in ".ctx/local.md" ".claude/settings.local.json" ".claude/skills/_library/" ".claude/bootstrap/" ".claude-backup/" "CLAUDE.local.md"; do
  grep -qF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
done
```

### Step 8 — Cleanup

```bash
rm -rf /tmp/claude-gen-update
```

### Step 9 — Report

```
Framework updated.

  Backup     : .claude-backup/{timestamp}/
  Commands   : updated
  Agents     : updated
  Skills lib : {count} cached + {count} local
  Bootstrap  : updated
  TODO.md    : {patched / already up to date}
  CLAUDE.md  : {patched / no changes needed}
  .gitignore : {patched / already up to date}

Not touched: .ctx/, .claude/rules/, active skills

⚠️ Important: type /exit then reopen claude to load updated config
```

### What is NOT touched

- `.ctx/` — all context files preserved
- `.claude/rules/` — all rules preserved (including custom)
- `.claude/skills/{active}/` — active skills preserved (run /claude-gen-sync-skills to update these)
- `TODO.md` content — only appends missing sections
