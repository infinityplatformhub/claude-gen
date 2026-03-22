# Upgrade Guide

## Updating to Latest Version

### Recommended: Use /claude-gen-update

From within Claude Code in your project:
```
/claude-gen-update
```

This automatically:
- Downloads latest framework from GitHub
- Backs up current commands/agents/rules to `.claude-backup/{timestamp}/`
- Updates commands, agents, skills library, bootstrap templates
- Patches `TODO.md` (adds Roadmap/Ideas sections if missing)
- Patches `.gitignore` (adds missing entries)
- Tells you to `/exit` and restart for changes to take effect

**Not touched:** CLAUDE.md, TODO.md content, .ctx/, .claude/rules/, active skills.

### Alternative: Re-install from Terminal (Mac/Linux/WSL)

```
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

Same result as `/claude-gen-update` but runs outside Claude Code. Also creates timestamped backup.

### Alternative: Plugin Re-install (all platforms)

```
/plugin install infinityplatformhub/claude-gen
```

---

## Migrating from Old Framework (.claude/context/)

If your project uses old paths like `.claude/context/` and `.claude/memory/`:

### What Changed

| Old | New | Why |
|-----|-----|-----|
| `.claude/context/active-tasks.md` | `.ctx/active-tasks.md` | No permission prompts |
| `.claude/context/recent-changes.md` | `.ctx/recent-changes.md` | Same |
| `.claude/memory/learned.md` | `.ctx/learned.md` | Same |
| `.claude/memory/local.md` | `.ctx/local.md` | Same |

### Migration Steps

```bash
# 1. Install latest framework (auto-backup)
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh

# 2. Open Claude Code
claude

# 3. Run init — it detects old framework and migrates automatically
/claude-gen-init
```

The init agent (Scenario C) will:
- Move content from `.claude/context/` → `.ctx/`
- Move content from `.claude/memory/` → `.ctx/`
- Update CLAUDE.md @-imports to point to `.ctx/`
- Delete old directories after migration
- Preserve all custom rules and task history

---

## Updating Individual Skills

```
/claude-gen-sync-skills
```

Checks upstream repos for newer versions, validates file integrity, updates with your approval.

Or add a specific skill:
```
/claude-gen-add-skill react-expert
```

---

## Adding Custom Skills

### Create a Project-Specific Skill

```bash
mkdir -p .claude/skills/my-custom-skill
```

Create `.claude/skills/my-custom-skill/SKILL.md`:
```yaml
---
name: my-custom-skill
description: What it does and when to use it.
---

# My Custom Skill

Instructions for Claude...
```

### Add to Framework (for All Projects)

1. Create in `skills-library/` (root level, not `_cache/`)
2. Add to `_index.json` under `skills` with `"source": "local"`
3. Add to relevant `stack_profiles`

### Add External Skill from Community

1. Clone source repo, verify SKILL.md + references exist
2. Copy to `skills-library/_cache/{name}/`
3. Add to `_registry.json` with source, path, files, file_count
4. Add to `_index.json` with `"source": "external"`
