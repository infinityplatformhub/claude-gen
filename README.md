# Claude Code General Framework

A production-ready framework for Claude Code projects. Provides autonomous project management, enforced code quality, persistent context, and a curated skills library — all configured automatically from your codebase.

## Features

- **Autonomous PM** — Claude manages tasks, decides commit scope, splits work into subtasks
- **Enforced Commit Quality** — pre-commit checklist, task ID required, user approval gate
- **Persistent Context** — task state, learned gotchas, and project knowledge survive across sessions
- **18 Curated Skills** — language, framework, testing, security, and DevOps expertise auto-loaded per stack
- **12 Stack Profiles** — Go, Python, PHP, Node.js, React — auto-detected, zero config
- **Impact Rules** — "changed X → must update Y" enforced automatically
- **Roadmap & Ideas** — defer work naturally, tracked in TODO.md without cluttering the backlog
- **Offline-Ready** — all skills cached locally with pinned commit SHAs

## Quick Start

Install:
```
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

Then open Claude Code and run:
```
/init-project
```

Existing `.claude/` and `.ctx/` files are automatically backed up before install.

See [Getting Started](docs/getting-started.md) for more options.

## Stack Profiles

Auto-detected during `/init-project`. Each profile selects the right skills and rules.

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

18 skills from trusted sources, cached with pinned commit SHAs.

| Source | Skills |
|--------|--------|
| [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | golang-pro, python-pro, typescript-pro, react-expert, nextjs-developer, php-pro, laravel-specialist, django-expert, fastapi-expert |
| [antfu/skills](https://github.com/antfu/skills) | nuxt, vue, vitest |
| [getsentry/skills](https://github.com/getsentry/skills) | security-audit |
| Self-authored | debugging, docker, git-advanced, golang-testing, migration-database |

See [Skills Guide](docs/skills-guide.md) for details.

## Commands

| Command | Description |
|---------|-------------|
| `/claude-gen-init` | Full project initialization with stack detection |
| `/claude-gen-update` | Update framework to latest version (auto-patch) |
| `/claude-gen-add-skill [name]` | Add a skill from the library |
| `/claude-gen-sync-skills` | Update cached skills from upstream |

`/init-project` also works as alias for `/claude-gen-init`.

## Architecture

```
skills-library/
├── _index.json         skill → stack profile mapping
├── _registry.json      external sources with pinned commit SHAs
├── _cache/             community skills (verified, offline-ready)
└── {local}/            self-authored universal skills
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
