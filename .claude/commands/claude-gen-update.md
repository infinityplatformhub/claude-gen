---
name: claude-gen-update
description: Update claude-gen framework to latest version.
             Downloads latest from GitHub, patches missing features, preserves project config.
---

## Update Framework

Pull the latest claude-gen framework and apply updates to this project.

### Step 1 — Download latest

```bash
git clone --depth 1 --quiet https://github.com/infinityplatformhub/claude-gen.git /tmp/claude-gen-update
```

If clone fails → report error, clean up `/tmp/claude-gen-update`, and stop.

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

### Step 5 — Patch CLAUDE.md (rename old commands)

If CLAUDE.md contains old command names, update them:

```bash
if [ -f CLAUDE.md ]; then
  sed -i 's|/init-project|/claude-gen-init|g; s|/add-skill|/claude-gen-add-skill|g; s|/sync-skills|/claude-gen-sync-skills|g' CLAUDE.md
fi
```

Also fix the `/init` block message if present (should be informational, not blocking):

```bash
if grep -q "Do NOT run" CLAUDE.md 2>/dev/null; then
  sed -i 's|Do NOT run `/init`.*|This file is managed by claude-gen framework. Use `/claude-gen-init` to re-initialize, `/claude-gen-update` to update.|' CLAUDE.md
fi
```

### Step 6 — Patch .gitignore

Ensure these entries exist (add each one only if missing):

```
.ctx/local.md
.claude/settings.local.json
.claude/skills/_library/
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md
```

```bash
for entry in ".ctx/local.md" ".claude/settings.local.json" ".claude/skills/_library/" ".claude/bootstrap/" ".claude-backup/" "CLAUDE.local.md"; do
  grep -qF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
done
```

### Step 7 — Cleanup

```bash
rm -rf /tmp/claude-gen-update
```

Always clean up, even if earlier steps failed.

### Step 8 — Report

```
Framework updated.

  Backup    : .claude-backup/{timestamp}/
  Commands  : updated (claude-gen-init, claude-gen-update, claude-gen-add-skill, claude-gen-sync-skills)
  Agents    : updated (project-init-agent)
  Skills    : {count} cached + {count} local
  Bootstrap : updated
  TODO.md   : {patched / already up to date}
  .gitignore: {patched / already up to date}

Not touched: CLAUDE.md, .ctx/, .claude/rules/, active skills

⚠️ Important: type /exit then reopen claude to load updated config
```

### What is NOT touched

- `CLAUDE.md` — project system prompt (user-managed)
- `TODO.md` content — only appends missing sections
- `.ctx/` — all context files preserved
- `.claude/rules/` — all rules preserved (including custom)
- `.claude/skills/{active}/` — active skills preserved
