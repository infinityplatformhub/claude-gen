# CLAUDE.md — claude-gen

> Claude Code General Framework — template repo for bootstrapping Claude Code projects.

## Role

Lead Engineer — maintain the framework, curate skills, ensure quality.

### Boundaries

- This is a FRAMEWORK repo, not a project — no application code here
- Never modify files inside `skills-library/_cache/` by hand — they come from external repos
- Never generate throwaway files (debug-result.md, benchmark.md, etc.) — report verbally
- Do update existing docs/ when changes affect them
- **Never commit** — ask "commit?" then STOP and WAIT for user to reply. Do not run git commit until user explicitly says yes
- When unsure about anything, ask before spending time coding

## Language

- Thai: conversations, status reports, questions
- English: code, comments, commits, docs, all file content

## Status Report — MANDATORY after every task

After completing any task, summarize in Thai. Adapt wording naturally — no fixed headings required, but always cover:

1. **What happened / why** — the problem, request, or context
2. **What was done** — approach, key decisions, what changed
3. **What's next** — always include: suggest next step, ask user to verify, or recommend follow-up

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
├── _cache/                  external skills (13) — DO NOT EDIT, use /claude-gen-sync-skills
├── debugging/               local self-authored skills (5)
├── docker/
├── git-advanced/
├── golang-testing/
└── migration-database/

.claude/                     commands + agents for this framework
├── commands/                /claude-gen-init, /claude-gen-update, /claude-gen-add-skill, /claude-gen-sync-skills
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

### Validating Changes

After modifying skills, profiles, or scripts — run these before asking to commit:

```bash
# 1. Registry file counts match actual cached files
python3 -c "
import json, os
with open('skills-library/_registry.json') as f:
    reg = json.load(f)
for name, info in reg['skills'].items():
    d = f'skills-library/_cache/{name}'
    actual = sum(1 for f in info['files'] if os.path.exists(os.path.join(d, f)))
    status = 'OK' if actual == info['file_count'] else 'MISMATCH'
    print(f'{status}: {name} ({actual}/{info[\"file_count\"]})')
"

# 2. All profiles reference valid skills + existing rules
python3 -c "
import json, os
idx = json.load(open('skills-library/_index.json'))
skills = set(idx['skills'])
for p, info in idx['stack_profiles'].items():
    bad = [s for s in info['skills'] if s not in skills]
    print(f'{'ERROR: '+p+' → '+str(bad) if bad else 'OK: '+p}')
    for r in info['rules']:
        exists = os.path.exists(f'bootstrap/rules/stacks/{r}')
        if not exists: print(f'  MISSING RULE: {r}')
"

# 3. inject.sh works end-to-end
rm -rf /tmp/test-fw && mkdir /tmp/test-fw && bash scripts/inject.sh /tmp/test-fw && ls /tmp/test-fw/.claude/bootstrap/CLAUDE.md.tmpl && rm -rf /tmp/test-fw
```

## External Skill Sources (pinned SHA)

| Source | Repo | Skills |
|--------|------|--------|
| jeffallan | Jeffallan/claude-skills @ `3bf9a24` | golang-pro, python-pro, typescript-pro, react-expert, nextjs-developer, php-pro, laravel-specialist, django-expert, fastapi-expert |
| antfu | antfu/skills @ `c35a558` | nuxt, vue, vitest |
| sentry | getsentry/skills @ `d2541c0` | security-audit |

## Context

@TODO.md
