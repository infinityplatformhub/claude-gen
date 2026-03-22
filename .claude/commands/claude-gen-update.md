---
name: claude-gen-update
description: Update claude-gen framework to latest version.
             Downloads latest from GitHub, patches missing features, preserves project config.
---

## Update Framework

Pull the latest framework version and apply updates to this project.

### Step 1 — Download latest

```bash
git clone --depth 1 --quiet https://github.com/infinityplatformhub/claude-gen.git /tmp/claude-gen-update
```

If clone fails → report error and stop.

### Step 2 — Backup current framework files

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p .claude-backup/$TIMESTAMP
```

Backup (exclude _library and bootstrap — they get replaced):
- `.claude/commands/` → backup
- `.claude/agents/` → backup
- `.claude/rules/` → backup

### Step 3 — Update framework files

Replace with latest:
```bash
cp /tmp/claude-gen-update/.claude/commands/*.md .claude/commands/
cp /tmp/claude-gen-update/.claude/agents/*.md .claude/agents/
cp -r /tmp/claude-gen-update/skills-library/. .claude/skills/_library/
cp -r /tmp/claude-gen-update/bootstrap/. .claude/bootstrap/
```

### Step 4 — Patch TODO.md

If `TODO.md` exists but missing `## Roadmap` section → append:
```markdown

---

## Roadmap

> No task ID yet — move to backlog sections above when ready to execute.

_Empty_

---

## Ideas

> Captured for future consideration. Not committed to.

_Empty_
```

### Step 5 — Patch .gitignore

Ensure these entries exist (add if missing):
```
.ctx/local.md
.claude/settings.local.json
.claude/skills/_library/
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md
```

### Step 6 — Cleanup

```bash
rm -rf /tmp/claude-gen-update
```

### Step 7 — Report

```
Framework updated.

  Backup    : .claude-backup/{timestamp}/
  Commands  : updated (init-project, add-skill, sync-skills, update-framework)
  Agents    : updated (project-init-agent)
  Skills    : {count} cached + {count} local
  Bootstrap : updated
  TODO.md   : {patched / already up to date}
  .gitignore: {patched / already up to date}

Not touched: CLAUDE.md, .ctx/, .claude/rules/, active skills

⚠️ พิมพ์ /exit แล้วเปิด claude ใหม่เพื่อ load config ล่าสุด
```

### What is NOT touched

- `CLAUDE.md` — project system prompt (user-managed)
- `TODO.md` content — only appends missing sections
- `.ctx/` — all context files preserved
- `.claude/rules/` — all rules preserved (including custom)
- `.claude/skills/{active}/` — active skills preserved
