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

### Step 5 — Patch CLAUDE.md (MANDATORY — do not skip)

You MUST read `CLAUDE.md` and check EVERY item below. Do NOT skip this step.

For each item: read the file, check if the issue exists, fix if needed, report what you did.

1. **"/init" block message** — look for "Do NOT run `/init`" → change to:
   `This file is managed by claude-gen framework. Use /claude-gen-init to re-initialize, /claude-gen-update to update.`

2. **Old doc rules** — look for "Never create docs, reports, or analysis files" → change to:
   - `Never generate throwaway files (debug-result.md, benchmark.md, etc.) — report verbally`
   - `Do update existing docs when changes affect them`

3. **Missing pre-commit item** — look for pre-commit checklist, check if "No duplicate routes or components" exists → add if missing

4. **Old status report** — look for "Issues found" or "Next — follow-up (only if applicable)" → update to:
   - Always cover: what happened/why, what was done, what's next
   - "What's next" is always required
   - No fixed headings — adapt wording naturally

5. **Weak commit rule** — look for "always ask user to approve before committing" or "Never commit automatically" → change to:
   `Never commit — ask "commit?" then STOP and WAIT for user to reply. Do not run git commit until user explicitly says yes. Asking is not approval.`

Report each item: "checked — {fixed / already correct}"
Do NOT rewrite or restructure CLAUDE.md — only fix the items above.

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
for entry in ".ctx/local.md" ".claude/settings.local.json" ".claude/skills/_library/" ".claude/bootstrap/" ".claude-backup/" ".playwright-mcp/" "CLAUDE.local.md"; do
  grep -qF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
done
```

### Step 8 — Patch .dockerignore

If project has `Dockerfile` or `docker-compose*.yml` or `.dockerignore`, ensure these entries exist:

```bash
if [ -f Dockerfile ] || [ -f docker-compose.yml ] || [ -f docker-compose.yaml ] || [ -f .dockerignore ]; then
  for entry in ".ctx/" ".claude/" ".claude-backup/" ".playwright-mcp/" "CLAUDE.md" "CLAUDE.local.md" "TODO.md" ".git"; do
    grep -qF "$entry" .dockerignore 2>/dev/null || echo "$entry" >> .dockerignore
  done
fi
```

### Step 9 — Cleanup

```bash
rm -rf /tmp/claude-gen-update
```

### Step 10 — Report

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
