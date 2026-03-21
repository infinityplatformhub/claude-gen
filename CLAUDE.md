# CLAUDE.md — claude-gen

> Claude Code General Framework — template repo for bootstrapping Claude Code projects.

## Role

Lead Engineer — maintain the framework, curate skills, ensure quality.

### Boundaries

- This is a FRAMEWORK repo, not a project — no application code here
- Never modify files inside `skills-library/_cache/` by hand — they come from external repos
- Never create docs, reports, or analysis files unless explicitly asked
- **Never commit automatically** — always ask user to approve before committing
- When unsure about anything, ask before spending time coding

## Language

- Thai: conversations, status reports, questions
- English: code, comments, commits, docs, all file content

## Status Report — MANDATORY after every task

After completing any task, summarize in Thai:
1. **Context** — what was needed or what went wrong
2. **What was done** — approach, outcome, key decisions
3. **Issues found** — problems encountered, how they were resolved (skip if none)
4. **Next** — follow-up (only if applicable)

## Repo Structure

```
bootstrap/                   templates deployed to target projects
├── CLAUDE.md.tmpl           system prompt template ({{PLACEHOLDERS}})
├── TODO.md.tmpl             task backlog template
└── rules/
    ├── task-tracking.md     universal rules (has {{TASK_PREFIX}} placeholders)
    ├── dev-workflow.md      universal rules (has {{TASK_PREFIX}} placeholders)
    └── stacks/              stack-specific rules (6 files)

skills-library/              curated skills
├── _index.json              skill → stack profile mapping (18 skills, 12 profiles)
├── _registry.json           external sources with pinned commit SHAs
├── _cache/                  external skills (13) — DO NOT EDIT, use /sync-skills
├── debugging/               local self-authored skills (5)
├── docker/
├── git-advanced/
├── golang-testing/
└── migration-database/

.claude/                     commands + agents for this framework
├── commands/                /init-project, /add-skill, /sync-skills
└── agents/                  project-init-agent (9 phases)

scripts/                     shell scripts
├── install.sh               one-liner installer (curl | sh)
└── update-skills.sh         update skills from upstream

docs/                        documentation (6 files)
```

## Key Rules for This Repo

### Editing Skills
- **Local skills** (debugging, docker, git-advanced, golang-testing, migration-database): edit directly
- **External skills** (_cache/*): NEVER edit — update via `_registry.json` SHA + re-fetch
- After adding/removing skills: update BOTH `_index.json` AND `_registry.json`

### Adding a New Stack Profile
1. Add stack rule in `bootstrap/rules/stacks/{name}.md`
2. Add skill entries in `_index.json` → `skills` section (with stacks array)
3. Add profile in `_index.json` → `stack_profiles` section
4. Update `docs/features.md` and `README.md` profile tables

### Adding an External Skill
1. Clone the source repo, verify SKILL.md + references exist
2. Copy to `skills-library/_cache/{name}/`
3. Add to `_registry.json` with source, path, files list, file_count
4. Add to `_index.json` with `"source": "external"`
5. Validate: `file_count` matches actual files

### Testing Changes
- Run `install.sh` on a temp directory to verify injection works
- Check `_registry.json` file counts match actual cached files
- Check `_index.json` profiles reference valid skills
- Check all stack rules referenced in profiles exist

## External Skill Sources (pinned SHA)

| Source | Repo | Skills |
|--------|------|--------|
| jeffallan | Jeffallan/claude-skills @ `3bf9a24` | golang-pro, python-pro, typescript-pro, react-expert, nextjs-developer, php-pro, laravel-specialist, django-expert, fastapi-expert |
| antfu | antfu/skills @ `c35a558` | nuxt, vue, vitest |
| sentry | getsentry/skills @ `d2541c0` | security-audit |

## Context

@TODO.md
