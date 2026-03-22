# Upgrade Guide

## From Old Framework (src/ based) to v2

If your project uses the old framework with `.claude/context/` and `.claude/memory/`:

### What Changed

| Old (v1) | New (v2) | Why |
|----------|----------|-----|
| `.claude/context/active-tasks.md` | `.ctx/active-tasks.md` | No permission prompts for frequent writes |
| `.claude/context/recent-changes.md` | `.ctx/recent-changes.md` | Same |
| `.claude/memory/learned.md` | `.ctx/learned.md` | Same |
| `.claude/memory/local.md` | `.ctx/local.md` | Same |
| `.claude/stacks/` | `bootstrap/rules/stacks/` | Stacks are now in the framework, not in projects |
| Skills flat in `.claude/skills/` | `_library/_cache/` + active | Two-tier: library (all) vs. active (project) |
| No commands | `.claude/commands/` | /claude-gen-init, /claude-gen-add-skill, /claude-gen-sync-skills |
| Manual init (INIT.md) | Auto init (project-init-agent) | 9-phase automated setup |

### Migration Steps

```bash
# 1. Backup your current framework files
cp -r .claude/ .claude.backup/

# 2. Create .ctx/ and move context files
mkdir -p .ctx
mv .claude/context/active-tasks.md .ctx/active-tasks.md 2>/dev/null
mv .claude/context/recent-changes.md .ctx/recent-changes.md 2>/dev/null
mv .claude/memory/learned.md .ctx/learned.md 2>/dev/null
mv .claude/memory/local.md .ctx/local.md 2>/dev/null

# 3. Inject the new framework (safe — won't overwrite .ctx/ files)
/path/to/claude-general-template/scripts/inject.sh .

# 4. Update CLAUDE.md imports
# Change:
#   @.claude/context/active-tasks.md → @.ctx/active-tasks.md
#   @.claude/context/recent-changes.md → @.ctx/recent-changes.md
#   @.claude/memory/learned.md → @.ctx/learned.md
#   @.claude/memory/local.md → @.ctx/local.md

# 5. Update .gitignore
# Remove: .claude/memory/local.md
# Add: .ctx/local.md

# 6. Clean up old directories
rm -rf .claude/context/ .claude/memory/ .claude/stacks/

# 7. Run init to finalize
claude
/claude-gen-init
# Choose: "Existing project, has old framework" when asked
```

### What /claude-gen-init Preserves
- Your custom rules in `.claude/rules/`
- Your task history in `.ctx/active-tasks.md` and `.ctx/recent-changes.md`
- Your learned gotchas in `.ctx/learned.md`
- Custom sections in CLAUDE.md

### What Gets Updated
- CLAUDE.md @-imports (point to .ctx/ instead of .claude/context/)
- New commands added to `.claude/commands/`
- Skills library installed to `.claude/skills/_library/`

---

## Updating Framework Version

When a new version of claude-general-template is released:

### Quick Update (Skills + Commands Only)

```bash
# Re-run inject.sh — safe, won't overwrite project files
/path/to/claude-general-template/scripts/inject.sh .
```

This updates:
- `.claude/commands/*.md`
- `.claude/agents/*.md`
- `.claude/skills/_library/` (all skills)

Does NOT touch:
- `.ctx/` files
- `.claude/rules/` (your custom rules)
- `.claude/skills/{active-skills}/` (your active skills)
- `CLAUDE.md`, `TODO.md`

### Full Update (Including Rules)

```bash
# 1. Re-inject
/path/to/claude-general-template/scripts/inject.sh .

# 2. Compare and update rules manually
diff .claude/rules/task-tracking.md /path/to/framework/bootstrap/rules/task-tracking.md
diff .claude/rules/dev-workflow.md /path/to/framework/bootstrap/rules/dev-workflow.md

# 3. Update active skills to latest cached versions
/claude-gen-sync-skills
```

### Updating Individual Skills

```
# Inside Claude Code
/claude-gen-sync-skills
```

Or manually:
```bash
# Update a specific skill from framework
cp -r /path/to/framework/skills-library/_cache/security-audit/ \
  .claude/skills/_library/_cache/security-audit/

# Also update active copy if skill is active
cp -r .claude/skills/_library/_cache/security-audit/ \
  .claude/skills/security-audit/
```

---

## Adding Custom Skills

### Create a Local Skill

```bash
mkdir -p .claude/skills/my-custom-skill
cat > .claude/skills/my-custom-skill/SKILL.md << 'EOF'
---
name: my-custom-skill
description: What it does and when to use it.
---

# My Custom Skill

Instructions for Claude...
EOF
```

### Add to Framework for All Projects

1. Create the skill in `skills-library/` (root level, not `_cache/`)
2. Add to `_index.json` under `skills` with `"source": "local"`
3. Add to relevant `stack_profiles`

### Add an External Skill from Community

1. Add entry to `_registry.json`:
```json
"new-skill": {
  "source": "author-name",
  "path": "skills/new-skill",
  "files": ["SKILL.md", "references/..."],
  "file_count": 3
}
```
2. Add source to `sources` if new author
3. Clone repo, copy to `_cache/new-skill/`
4. Add to `_index.json`
