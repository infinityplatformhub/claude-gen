# Skills Guide

## How Skills Work

A skill is a set of instructions that teaches Claude domain-specific expertise. When triggered, Claude reads the SKILL.md and follows its patterns.

Skills are optional — Claude already knows most languages and frameworks. Skills add **project-specific conventions, patterns, and constraints** that go beyond general knowledge. Projects with unregistered stacks still work using universal skills + Claude's built-in expertise.

### Skill Structure
```
skill-name/
├── SKILL.md              main instructions (loaded when triggered)
└── references/           detailed guides (loaded on-demand)
    ├── topic-a.md
    └── topic-b.md
```

### Loading Order
1. **Name + description** — always visible to Claude (~100 words)
2. **SKILL.md body** — loaded when skill triggers (<500 lines ideal)
3. **References** — loaded when Claude needs deep detail on a specific topic

This keeps context window efficient — Claude only loads what it needs.

---

## Skill Categories

### Language Skills
| Skill | What It Covers | References |
|-------|---------------|-----------|
| golang-pro | Go 1.22+, goroutines, channels, GORM, error handling | concurrency, interfaces, generics, testing, project-structure |
| python-pro | Python 3.12+, async/await, typing, packaging | async-patterns, packaging, standard-library, testing, type-system |
| typescript-pro | TypeScript 5+, advanced types, generics, strict mode | advanced-types, configuration, patterns, type-guards, utility-types |

### Framework Skills
| Skill | What It Covers | References |
|-------|---------------|-----------|
| react-expert | React 18/19, hooks, server components, state | hooks-patterns, react-19-features, server-components, performance, state-management, testing-react |
| nextjs-developer | Next.js 14/15, App Router, server actions | app-router, data-fetching, deployment, server-actions, server-components |
| nuxt | Nuxt 3/4, SSR, composables, server routes | 18 files covering core, features, rendering, best-practices, advanced |
| vue | Vue 3, Composition API, script setup | script-setup-macros, core-new-apis, advanced-patterns |

### Testing Skills
| Skill | What It Covers | References |
|-------|---------------|-----------|
| golang-testing | Table-driven tests, testcontainers, mocks, fuzzing, benchmarks | — (self-contained) |
| vitest | Modern JS/TS testing, mocking, coverage, type testing | 16 files covering core, features, advanced |

### DevOps & Infra Skills
| Skill | What It Covers | References |
|-------|---------------|-----------|
| docker | Dockerfile, Compose, multi-stage builds, healthchecks | — (self-contained) |
| migration-database | Multi-dialect DB migrations, GORM/Alembic/Prisma, rollback | — (self-contained) |

### Universal Skills
| Skill | What It Covers | References |
|-------|---------------|-----------|
| git-advanced | Rebase, bisect, worktrees, hooks, recovery | — (self-contained) |
| debugging | Structured root-cause methodology, common patterns | — (self-contained) |
| security-audit | OWASP, injection, XSS, auth, confidence-based review | 17 vulnerability refs + 2 language guides + 1 infra guide |

### Opt-in Skills
Not auto-loaded by any profile — offered at `/claude-gen-init` / `/claude-gen-update` only when a backend is detected, or added manually.

| Skill | What It Covers | References |
|-------|---------------|-----------|
| contract-first-api | API as single source of truth: OpenAPI-from-code, single-source markdown docs, `/llms.txt` agent on-ramp, generated client types, docs↔guard drift test | — (self-contained) |

Add it anytime with `/claude-gen-add-skill contract-first-api`.

---

## Managing Skills

### View Available Skills
```
/claude-gen-add-skill
```
Lists all skills in the library and which are already active.

### Activate a Skill
```
/claude-gen-add-skill python-pro
/claude-gen-add-skill vitest
```

### Update Skills
```
/claude-gen-sync-skills
```
Checks upstream repos for newer versions, validates integrity, updates with approval.

### Deactivate a Skill
```bash
# Simply remove the active copy
rm -rf .claude/skills/skill-name/
```

---

## External vs Local Skills

### External Skills (in `_cache/`)
- Sourced from community repos (Jeffallan, antfu, Sentry)
- Pinned to specific commit SHA in `_registry.json`
- Updated via `/claude-gen-sync-skills`
- Quality: battle-tested by their communities

### Local Skills (at root level)
- Self-authored for this framework
- Universal (work with any stack)
- Updated by editing directly

---

## Adding a New Skill to the Framework

### From Community
1. Find the skill on GitHub (check Jeffallan/claude-skills first — 66+ skills)
2. Clone the repo, verify the skill has SKILL.md + references
3. Copy to `skills-library/_cache/{name}/`
4. Add to `_registry.json`:
   ```json
   "skill-name": {
     "source": "author-id",
     "path": "skills/skill-name",
     "files": ["SKILL.md", "references/..."],
     "file_count": 5
   }
   ```
5. Add to `_index.json` under `skills` and relevant `stack_profiles`

### Self-Authored
1. Create `skills-library/{name}/SKILL.md`
2. Add references if needed: `skills-library/{name}/references/`
3. Add to `_index.json` with `"source": "local"`

### SKILL.md Format
```yaml
---
name: skill-name
description: What it does. When to use it. Be specific for triggering.
---
```

Body: instructions, code examples, constraints (MUST DO / MUST NOT DO).

---

## Skill Sources

| Source | Skills Available | URL |
|--------|-----------------|-----|
| Jeffallan/claude-skills | 66+ (Go, Python, TS, React, Vue, Django, FastAPI, AWS, K8s, ...) | https://github.com/Jeffallan/claude-skills |
| antfu/skills | 18 (Nuxt, Vue, Vitest, Vite, Pinia, UnoCSS, ...) | https://github.com/antfu/skills |
| getsentry/skills | Security review (OWASP, confidence-based) | https://github.com/getsentry/skills |
| anthropics/skills | Official (skill-creator, pdf, docx, frontend-design, ...) | https://github.com/anthropics/skills |
| obra/superpowers | 20+ (TDD, git worktrees, brainstorming, ...) | https://github.com/obra/superpowers |
