# Changelog

## v2.1.0 — 2026-03-22

### Hybrid C Architecture
- Implemented registry + cache system for external skills
- Added `_registry.json` with pinned commit SHAs for all 9 external skills
- External skills stored in `_cache/` — git-tracked, works offline
- Self-authored universal skills remain at root level
- File integrity validation: count + file list matched against registry

### New Skills (+5)
- **python-pro** — Python 3.12+, async, typing, FastAPI/Django (from Jeffallan/claude-skills)
- **typescript-pro** — TypeScript 5+, advanced types, generics (from Jeffallan/claude-skills)
- **react-expert** — React 18/19, hooks, server components (from Jeffallan/claude-skills)
- **nextjs-developer** — Next.js 14/15, App Router, server actions (from Jeffallan/claude-skills)
- **vitest** — Modern JS/TS testing, mocking, coverage (from antfu/skills)

### New Stack Profiles (+4)
- `python-django` — Python Django backend
- `nodejs-express` — Node.js Express/Fastify backend
- `nodejs-react` — Node.js + React/Next.js
- `react-standalone` — React/Next.js with BaaS

### Improved Commands
- `/add-skill` — cache-first lookup, fetch from registry on miss, validation
- `/sync-skills` — upstream update check, SHA comparison, offline fallback

---

## v2.0.0 — 2026-03-22

### Architecture Restructure (Spec v2)
- Moved context files from `.claude/context/` and `.claude/memory/` to `.ctx/`
  - `.ctx/` is outside `.claude/` so Claude writes without permission prompts
- Created `bootstrap/` with templates (CLAUDE.md.tmpl, TODO.md.tmpl) and rules
- Created `skills-library/` with `_index.json` manifest
- Added `.claude/commands/` (init-project, add-skill, sync-skills)
- Added `.claude/agents/project-init-agent.md` (9-phase auto-init)
- Added `scripts/inject.sh` (POSIX sh) and `scripts/update-skills.sh`

### Skills (Initial Set)
- **golang-pro** — from Jeffallan/claude-skills (original with 5 references)
- **nuxt** — from antfu/skills (original with 18 references)
- **vue** — from antfu/skills (original with 3 references)
- **security-audit** — from getsentry/skills (22 references, confidence-based review)
- **git-advanced** — self-authored
- **golang-testing** — self-authored
- **debugging** — self-authored
- **docker** — self-authored
- **migration-database** — self-authored

### Stack Profiles (Initial)
- go-nuxt, go-react, go-api, python-fastapi, nodejs-nuxt

### Stack Rules
- go-backend.md, python-fastapi.md, nodejs-express.md, vue-nuxt.md, react.md

---

## v1.0.0 — 2026-03-22

### Initial Framework (in src/)
- CLAUDE.md template with PM autonomy, commit discipline, impact rules
- Task tracking system (T-xxx format, lifecycle, pre-commit checklist)
- Dev workflow rules (feature, bug fix, refactor, schema change checklists)
- Stack templates: Go backend, Python backend, React frontend, Vue/Nuxt frontend
- 4 skills: golang-pro, nuxt, vue, git-advanced
- Context management: active-tasks, recent-changes, learned, local memory
