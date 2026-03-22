# Deployment Guide

How to deploy this framework for your team.

---

## Option A: Private Git Repository

Recommended for teams. Fork and customize.

### Setup

```bash
# Fork or clone
git clone https://github.com/infinityplatformhub/claude-gen.git
cd claude-general-template

# Customize for your team
# 1. Add/remove skills from skills-library/
# 2. Edit bootstrap/rules/stacks/ for your conventions
# 3. Edit bootstrap/CLAUDE.md.tmpl for your defaults
# 4. Update _index.json with your stack profiles

# Push to your org's repo
git remote set-url origin git@github.com:infinityplatformhub/claude-gen.git
git push
```

### Usage by Team Members

```bash
# One-liner to inject into any project
git clone git@github.com:infinityplatformhub/claude-gen.git /tmp/framework
/tmp/framework/scripts/inject.sh .
```

Or add as a git alias:
```bash
git config --global alias.claude-init '!f() { git clone git@github.com:infinityplatformhub/claude-gen.git /tmp/claude-fw && /tmp/claude-fw/scripts/inject.sh "${1:-.}" && rm -rf /tmp/claude-fw; }; f'

# Then just:
git claude-init /path/to/project
```

---

## Option B: Shared Network Drive / NAS

For teams without Git hosting.

```bash
# Copy framework to shared location
cp -r claude-general-template /shared/tools/claude-framework

# Team members inject from shared drive
/shared/tools/claude-framework/scripts/inject.sh /path/to/project
```

---

## Option C: Manual Copy

For individual use.

```bash
# Just run inject.sh pointing at a project
./scripts/inject.sh /path/to/my/project
cd /path/to/my/project
claude
/claude-gen-init
```

---

## Keeping Projects Updated

### From Within Claude Code (recommended)

```
/claude-gen-update
```

Updates commands, agents, skills, bootstrap templates. Patches TODO.md and .gitignore. Creates backup before overwriting.

### Update Skills Only

```
/claude-gen-sync-skills
```

Checks upstream for newer skill versions, updates with approval.

### From Terminal (alternative)

```bash
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

Same as `/claude-gen-update` but runs outside Claude Code.

### What Gets Updated vs Preserved

| Updated | Preserved |
|---------|-----------|
| `.claude/commands/` | `CLAUDE.md` |
| `.claude/agents/` | `TODO.md` content |
| `.claude/skills/_library/` | `.ctx/` files |
| `.claude/bootstrap/` | `.claude/rules/` |
| `.gitignore` entries | Active skills |

---

## Team Conventions

### Recommended .gitignore Additions

These are added automatically by inject.sh, but verify:
```
.ctx/local.md
.claude/settings.local.json
CLAUDE.local.md
```

### What to Commit (Shared)
- `.ctx/active-tasks.md` — team sees what's in progress
- `.ctx/recent-changes.md` — team sees what was done
- `.ctx/learned.md` — shared gotchas
- `.claude/rules/` — shared coding rules
- `.claude/skills/` — active skills for the project
- `CLAUDE.md` — shared system prompt
- `TODO.md` — shared backlog

### What NOT to Commit (Personal)
- `.ctx/local.md` — machine-specific notes
- `.claude/settings.local.json` — personal Claude settings
- `CLAUDE.local.md` — personal prompt overrides
