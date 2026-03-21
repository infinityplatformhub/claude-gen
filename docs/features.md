# Features

## Task Tracking & PM Autonomy

Claude acts as Lead Engineer & PM with full authority to manage tasks.

### Task Lifecycle
```
Create → In Progress → Before Commit → Done → Archived
```

- **Auto-create tasks** — describe work, Claude opens a task immediately
- **Task ID format** — configurable prefix: `T-101`, `TASK-101`, `#101`
- **Status tracking** — `.ctx/active-tasks.md` (max 5 active) + `TODO.md` (full backlog)
- **History** — completed tasks move to `.ctx/recent-changes.md`

### PM Decisions (no need to ask)
- When to commit (PM decides, user approves)
- How to split work into subtasks
- When to bundle small changes into one commit

### Always Asks User First
- Deleting files or database tables
- Changing shared interfaces
- Adding new environment variables
- Committing (explicit user approval required)

---

## Commit Discipline

No rapid-fire commits. Fix completely, verify, confirm, commit once.

| Scenario | Strategy |
|----------|----------|
| Small bug fix (1-3 files) | Fix completely → 1 commit |
| Bug reveals more bugs | Fix all related → 1 commit |
| New feature (small) | Implement fully → 1 commit |
| New feature (large) | Split into subtasks → 1 commit per subtask |

### Pre-Commit Checklist (enforced)
1. Work is complete — not partial, not WIP
2. User confirmed the result
3. Task ID exists and tracked
4. Commit message includes task ID: `feat(T-xxx): ...`
5. `git diff --stat` reviewed
6. Impact Rules satisfied
7. No hardcoded secrets or debug logs

---

## Impact Rules

Customizable "if you changed X, you MUST also update Y" rules.

```markdown
| You Changed | MUST Also Update | Validation |
|-------------|-----------------|------------|
| backend/models/*.go | frontend/types/*.ts | Run type-checker |
| backend/handlers/*.go (new endpoint) | docs/API.md | Run api-validator |
```

Prevents drift between layers. Defined per-project in CLAUDE.md during init.

---

## Status Reports (Mandatory)

After every completed task, Claude summarizes:
1. **Context** — what was needed
2. **What was done** — approach, outcome, key decisions
3. **Next** — follow-up (only if applicable)

Reports use the project's configured conversation language.

---

## Skills Library (Hybrid Registry + Cache)

### Architecture
```
skills-library/
├── _index.json         skill → stack profile mapping
├── _registry.json      external sources with pinned commit SHAs
├── _cache/             community skills (verified, git-tracked, works offline)
└── {local}/            self-authored universal skills
```

### How It Works
- **Cache-first** — skills are pre-downloaded, no network needed for init
- **Pinned SHA** — external skills locked to specific commit, can't change unexpectedly
- **Validated** — file count and file list checked against `_registry.json`
- **Updatable** — `/sync-skills` checks upstream, updates with user approval

### Skill Types
| Type | Location | Examples |
|------|----------|---------|
| External (community) | `_cache/` | golang-pro, nuxt, react-expert, security-audit |
| Local (self-authored) | root level | debugging, docker, git-advanced |

### Progressive Loading
1. **Metadata** — name + description always in context (~100 words)
2. **SKILL.md body** — loaded when skill triggers (~200-500 lines)
3. **References** — loaded on-demand when specific topic needed (unlimited)

---

## 12 Stack Profiles

Auto-detected during `/init-project`. Each profile selects the right skills + rules.

| Profile | Backend | Frontend | Key Skills |
|---------|---------|----------|-----------|
| `go-nuxt` | Go | Nuxt 3 | golang-pro, nuxt, vue, golang-testing |
| `go-react` | Go | React | golang-pro, react-expert, golang-testing |
| `go-api` | Go | — | golang-pro, golang-testing |
| `python-fastapi` | FastAPI | — | python-pro |
| `python-django` | Django | — | python-pro |
| `nodejs-express` | Express | — | typescript-pro, vitest |
| `nodejs-nuxt` | Node.js | Nuxt 3 | typescript-pro, nuxt, vue, vitest |
| `nodejs-react` | Node.js | Next.js | typescript-pro, react-expert, nextjs-dev, vitest |
| `react-standalone` | BaaS | React | typescript-pro, react-expert, nextjs-dev, vitest |

All profiles include: git-advanced, debugging, docker, security-audit.

---

## Auto-Init (/init-project)

9-phase automated setup:

| Phase | What It Does |
|-------|-------------|
| 0. Language | Ask conversation language (English, Thai, etc.) |
| 1. Discover | Read README, package.json, go.mod, docker-compose, git history |
| 2. Confirm | Show auto-detected stack, ask max 4 questions |
| 3. Skills | Select and copy skills matching detected stack |
| 4. Custom Skills | Generate project-specific arch + workflow skills |
| 5. .ctx/ Files | Create active-tasks, recent-changes, learned, local |
| 6. .claude/ Files | Copy rules, stack templates, project reference |
| 7. CLAUDE.md | Generate or merge system prompt |
| 8. .gitignore | Add framework entries |
| 9. Report | Summary of everything created |

### Scenario Handling
- **New empty project** — asks more questions, generates skeleton
- **Existing project, no framework** — reads codebase extensively, minimal questions
- **Existing project, old framework** — migrates paths, preserves custom content
- **Has CLAUDE.md but no .ctx/** — creates .ctx/, updates imports

---

## Context Management

| Layer | Files | Survives Context Compact? |
|-------|-------|--------------------------|
| System prompt | `CLAUDE.md` | Yes |
| Local overrides | `CLAUDE.local.md` (gitignored) | Yes |
| Task state | `.ctx/active-tasks.md` | Yes (via @import) |
| Recent changes | `.ctx/recent-changes.md` | Yes (via @import) |
| Shared knowledge | `.ctx/learned.md` | Yes (via @import) |
| Local memory | `.ctx/local.md` (gitignored) | Yes (via @import) |
| Full backlog | `TODO.md` | No (read manually) |

### Why .ctx/ Outside .claude/
Files in `.ctx/` are written by Claude every session (task updates, learned gotchas). Placing them outside `.claude/` avoids permission prompts for frequent writes.

---

## Commands

| Command | Description |
|---------|-------------|
| `/init-project` | Full project initialization with stack detection |
| `/add-skill [name]` | Add a skill (cache-first, fetch on miss, validate) |
| `/sync-skills` | Update cached skills, discover new ones for your stack |

---

## Security (via Sentry's security-review)

The bundled security-audit skill uses **confidence-based reporting**:

| Confidence | Action |
|-----------|--------|
| HIGH | Vulnerable pattern + attacker-controlled input confirmed → **Report** |
| MEDIUM | Vulnerable pattern, input source unclear → **Note for verification** |
| LOW | Theoretical, best practice → **Do not report** |

Covers: injection, XSS, SSRF, CSRF, auth, crypto, deserialization, file security, business logic, modern threats, supply chain, API security — with language-specific guides for Python and JavaScript.
