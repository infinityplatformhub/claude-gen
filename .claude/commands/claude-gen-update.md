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

### Step 4 — Deploy enforcement hooks

```bash
mkdir -p .claude/hooks
cp .claude/bootstrap/hooks/ctx-budget.sh   .claude/hooks/
cp .claude/bootstrap/hooks/report-guard.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

**skill-router.sh** — special handling (it embeds the project's skill list):
- If `.claude/hooks/skill-router.sh` already exists → leave it (project-specific list inside)
- If missing AND `.claude/settings.json` has an old inline-echo `UserPromptSubmit` skill
  reminder → migrate: copy `skill-router.sh` from bootstrap, replace `{{SKILL_LIST}}` with
  the skill names found in `.claude/skills/` (excluding `_library`), remove the old inline hook
- If missing and no old hook → skip (user chose no auto-skill at init)

**settings.json** — read first, MERGE with `.claude/bootstrap/hooks/settings.json.tmpl`:
- Add the `PostToolUse` (ctx-budget) and `Stop` (report-guard) wiring if missing
- Add `UserPromptSubmit` (skill-router) wiring only if `.claude/hooks/skill-router.sh` exists
- Never remove or clobber the user's own hooks/keys
- Validate: `python3 -m json.tool .claude/settings.json > /dev/null`

### Step 4b — Patch TODO.md

If `TODO.md` exists but missing `## Roadmap` section:

```bash
if [ -f TODO.md ] && ! grep -q "## Roadmap" TODO.md; then
  printf "\n---\n\n## Roadmap\n\n> No task ID yet — move to backlog sections above when ready to execute.\n\n_Empty_\n\n---\n\n## Ideas\n\n> Captured for future consideration. Not committed to.\n\n_Empty_\n" >> TODO.md
fi
```

### Step 4c — Compress over-budget context files (immediate cleanup)

Don't leave bloated files for the hook to catch mid-task — clean them up NOW:

```bash
for f in .ctx/active-tasks.md .ctx/recent-changes.md .ctx/learned.md TODO.md; do
  [ -f "$f" ] && wc -c "$f"
done
```

Budgets: active-tasks 2048 · recent-changes 3072 · learned 6144 · TODO.md 16384

For each file over its budget:
1. **Archive first, never lose detail** — move full prose to `docs/changelog.md`
   (create if missing, format: `## Week of YYYY-MM-DD` + bullets)
2. Rewrite remaining entries as one-liners per `.claude/rules/task-tracking.md`:
   - active-tasks → `- 🔄 **T-xxx** title · goal · blockers: none`, max 5
   - recent-changes → `- YYYY-MM-DD **T-xxx** summary`, keep newest 10
   - learned → one line per gotcha; file-specific entries → path-scoped `.claude/rules/`; delete stale ones
   - TODO.md → ✅ prose entries become one-liners; duplicate task IDs removed; Completed overflow → changelog
3. Re-check size and report before/after bytes per file

If all files are within budget → report "already within budget" and move on.

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

5. **Commit Policy structure** — newer framework uses a `## Commit Policy` section with two
   modes (manual/auto). **Preserve the user's existing mode** — never flip auto→manual or vice
   versa. Only fix structure:
   - If the file still has the old hardcoded `## Pre-Commit Checklist` with no mode header →
     wrap it under `## Commit Policy` with a `> Mode: **MANUAL**` header (manual is the safe
     default for an un-migrated file), keeping the existing checklist items.
   - If a `## Commit Policy` section already exists → leave its mode and content as-is.
   - Either way, ensure pushing is noted as always-ask.

6. **local.md auto-import** — look for `@.ctx/local.md` in the Context section → remove the
   line and add: `` (`.ctx/local.md` is a machine-local scratchpad — NOT imported; read on demand.) ``
   (local.md is a scratchpad; importing it every session wastes tokens)

7. **Missing Focus/Token Discipline** — if `## Focus Discipline` or `## Token Discipline`
   sections don't exist, copy them from `.claude/bootstrap/CLAUDE.md.tmpl` (substitute the
   project's task prefix for `{{TASK_PREFIX}}`). These pair with the new enforcement hooks.

8. **Status report `→` marker** — the Status Report section must require ending every report
   with a final line starting with `→ ` (the report-guard hook checks for it). Add the
   requirement if missing — copy the wording from `.claude/bootstrap/CLAUDE.md.tmpl`.

9. **Version marker** — ensure `<!-- claude-gen v3 -->` exists near the top (line 2-3).
   Add or bump it if older/missing.

Report each item: "checked — {fixed / already correct}"
Do NOT rewrite or restructure CLAUDE.md — only fix the items above.

### Step 6 — Refresh framework-owned rules + review the rest

**Framework-owned rules** — `task-tracking.md` and `dev-workflow.md` are framework files,
not user content. Regenerate them from `.claude/bootstrap/rules/`:
1. Detect the project's task prefix from the existing `.claude/rules/task-tracking.md`
   (or CLAUDE.md Task Workflow section)
2. Copy both files from bootstrap, replacing ALL `{{TASK_PREFIX}}` with the detected prefix
3. This is how byte budgets + one-liner formats reach existing projects

**All other rules** (custom + project-reference.md + stack rules) — review only. Look for:
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
  Hooks      : {deployed / refreshed} (ctx-budget, report-guard{, skill-router})
  Cleanup    : {n files compressed, X KB → Y KB / all within budget}
  Skills lib : {count} cached + {count} local
  Bootstrap  : updated
  Rules      : task-tracking + dev-workflow refreshed, custom rules untouched
  TODO.md    : {patched / already up to date}
  CLAUDE.md  : {patched / no changes needed}
  .gitignore : {patched / already up to date}

Not touched: .ctx/, custom rules, active skills

⚠️ Important: type /exit then reopen claude to load updated config + hooks
```

### What is NOT touched

- `.ctx/` — all context files preserved
- `.claude/rules/` custom rules — preserved (framework-owned task-tracking/dev-workflow are refreshed)
- `.claude/skills/{active}/` — active skills preserved (run /claude-gen-sync-skills to update these)
- `.claude/hooks/skill-router.sh` — preserved if it exists (holds the project's skill list)
- `TODO.md` content — only appends missing sections
