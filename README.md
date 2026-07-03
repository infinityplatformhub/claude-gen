# Claude Code General Framework

A production-ready framework for Claude Code projects. Provides autonomous project management, enforced code quality, persistent context, and a curated skills library — all configured automatically from your codebase.

## Features

- **Autonomous PM** — Claude manages tasks, decides commit scope, splits work into subtasks
- **Enforcement Hooks** — byte budgets on context files, opt-in status-report enforcement, and skill routing enforced by real hooks, not agent memory
- **Enforced Commit Quality** — pre-commit checklist, task ID required, manual or auto commit mode
- **Preferences First** — one upfront prompt sets language, commit mode, auto-skill, and status-report enforcement; everything after is in your language
- **Persistent Context, Token-Lean** — one-line entries with hook-enforced budgets; detail lives once in the changelog
- **19 Curated Skills** — language, framework, testing, security, and DevOps expertise auto-loaded per stack, plus opt-in `contract-first-api` (API as single source of truth)
- **12 Stack Profiles** — Go, Python, PHP, Node.js, React — auto-detected, multi-stack mono repos supported
- **Impact Rules** — "changed X → must update Y" enforced automatically
- **Roadmap & Ideas** — defer work naturally, tracked in TODO.md without cluttering the backlog
- **Offline-Ready** — all skills cached locally with pinned commit SHAs

## Installation

### Option 1: Plugin (recommended)

From within Claude Code:
```
/plugin install infinityplatformhub/claude-gen
```

### Option 2: CLI

```
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

Then run:
```
/claude-gen-init
```

### Updating

```
/claude-gen-update
```

See [Getting Started](docs/getting-started.md) for more options.

## Stack Profiles

Auto-detected during `/claude-gen-init`. Each profile selects the right skills and rules.

| Profile | Backend | Frontend |
|---------|---------|----------|
| `go-nuxt` | Go | Nuxt 3 |
| `go-react` | Go | React/Next.js |
| `go-api` | Go | — |
| `python-fastapi` | FastAPI | — |
| `python-django` | Django | — |
| `php-laravel` | Laravel | — |
| `php-api` | PHP API | — |
| `php-react` | PHP | React |
| `nodejs-express` | Express | — |
| `nodejs-nuxt` | Node.js | Nuxt 3 |
| `nodejs-react` | Node.js | React/Next.js |
| `react-standalone` | BaaS | React/Next.js |

## Skills

19 skills — 13 from external sources (cached with pinned commit SHAs) + 6 self-authored.

| Source | Skills |
|--------|--------|
| [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | golang-pro, python-pro, typescript-pro, react-expert, nextjs-developer, php-pro, laravel-specialist, django-expert, fastapi-expert |
| [antfu/skills](https://github.com/antfu/skills) | nuxt, vue, vitest |
| [getsentry/skills](https://github.com/getsentry/skills) | security-audit |
| Self-authored | debugging, docker, git-advanced, golang-testing, migration-database, contract-first-api¹ |

¹ `contract-first-api` is opt-in — offered at init/update only when a backend is detected. Not auto-loaded by any profile.

See [Skills Guide](docs/skills-guide.md) for details.

## Commands

| Command | Description |
|---------|-------------|
| `/claude-gen-init` | Full project initialization with stack detection |
| `/claude-gen-update` | Update framework to latest version (auto-patch) |
| `/claude-gen-add-skill [name]` | Add a skill from the library |
| `/claude-gen-sync-skills` | Update cached skills from upstream |


## Architecture

```
skills-library/
├── _index.json         skill → stack profile mapping
├── _registry.json      external sources with pinned commit SHAs
├── _cache/             community skills (verified, offline-ready)
└── {local}/            self-authored universal skills

bootstrap/
├── CLAUDE.md.tmpl      system prompt template
├── TODO.md.tmpl        backlog template
├── rules/              universal + stack-specific rules
└── hooks/              enforcement hooks (ctx-budget, report-guard, skill-router)
```

## Documentation

| Doc | Description |
|-----|-------------|
| [Getting Started](docs/getting-started.md) | Setup for new and existing projects |
| [Features](docs/features.md) | Complete feature reference |
| [Skills Guide](docs/skills-guide.md) | Managing and adding skills |
| [Deployment Guide](docs/deployment-guide.md) | Team deployment and updating |
| [Migration Flow](docs/migration-flow.md) | How install and init work step-by-step |
| [Changelog](docs/changelog.md) | Version history |

## License

Framework: Use freely. Customize for your team.
External skills: MIT — see LICENSE in each skill directory.
