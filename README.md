# Claude Code General Framework

A reusable framework template for Claude Code projects. Structured task tracking, commit discipline, PM autonomy, curated skills library, and automated project initialization — stack-agnostic.

## Quick Start

```bash
# One-liner: install into current project
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh

# Then open Claude Code and run:
/init-project
```

If you have existing `.claude/` or `.ctx/` files, they're automatically backed up to `.claude-backup/` before install.

See [Getting Started](docs/getting-started.md) for more options.

## What You Get

- **14 curated skills** — 9 from community (pinned SHA, verified) + 5 self-authored
- **9 stack profiles** — Go, Python, Node.js, React combinations auto-detected
- **Task tracking** — PM autonomy, commit discipline, impact rules
- **Auto-init** — 9-phase setup: detect stack, select skills, generate config
- **Offline-ready** — all skills cached locally, no network required

See [Features](docs/features.md) for details.

## Stack Profiles

| Profile | Backend | Frontend |
|---------|---------|----------|
| `go-nuxt` | Go | Nuxt 3 |
| `go-react` | Go | React/Next.js |
| `go-api` | Go | — |
| `python-fastapi` | FastAPI | — |
| `python-django` | Django | — |
| `nodejs-express` | Express | — |
| `nodejs-nuxt` | Node.js | Nuxt 3 |
| `nodejs-react` | Node.js | React/Next.js |
| `react-standalone` | BaaS | React/Next.js |

## Skills (14 total)

### External (community, cached with pinned SHA)
| Skill | Source |
|-------|--------|
| golang-pro, python-pro, typescript-pro, react-expert, nextjs-developer | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) |
| nuxt, vue, vitest | [antfu/skills](https://github.com/antfu/skills) |
| security-audit | [getsentry/skills](https://github.com/getsentry/skills) |

### Local (self-authored, universal)
debugging, docker, git-advanced, golang-testing, migration-database

See [Skills Guide](docs/skills-guide.md) for full details.

## Commands

| Command | Description |
|---------|-------------|
| `/init-project` | Full project initialization with stack detection |
| `/add-skill [name]` | Add skill (cache-first, fetch on miss) |
| `/sync-skills` | Update skills from upstream |

## Architecture

```
skills-library/
├── _index.json         skill → stack mapping
├── _registry.json      pinned commit SHAs for external skills
├── _cache/             community skills (verified, offline-ready)
└── {local}/            self-authored universal skills
```

External skills are pinned to specific commit SHAs — they can't change unexpectedly, work offline, and are validated on every sync.

## Documentation

| Doc | Description |
|-----|-------------|
| [Getting Started](docs/getting-started.md) | Setup guide for new and existing projects |
| [Features](docs/features.md) | Complete feature reference |
| [Skills Guide](docs/skills-guide.md) | How skills work, adding/managing skills |
| [Deployment Guide](docs/deployment-guide.md) | Team deployment, git alias, updating |
| [Upgrade Guide](docs/upgrade-guide.md) | Migrating from v1, updating framework |
| [Changelog](docs/changelog.md) | Version history |

## License

Framework: Use freely. Customize for your team.
External skills: MIT — see LICENSE in each skill directory.
