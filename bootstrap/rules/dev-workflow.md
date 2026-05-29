# Dev Workflow

> Auto-loaded every session. Daily development patterns.

---

## Start of Session

1. Read `.ctx/active-tasks.md` — what's in progress?
2. Read `.ctx/recent-changes.md` — what was done recently?
3. Check `.ctx/learned.md` — any gotchas to remember?
4. If context was compacted → also read `TODO.md` to rebuild full backlog
5. Ask user what to work on if unclear

---

## Adding a New Feature (full checklist)

```
[ ] Create task in .ctx/active-tasks.md + TODO.md
[ ] Create branch: feat/{{TASK_PREFIX}}xxx-description
[ ] Check existing code before creating new files
[ ] Implement following the project's established patterns
[ ] Update docs if new endpoints/APIs added
[ ] Update .env.example if new ENV vars added
[ ] Run tests + linter
[ ] Run validation agents (if applicable)
[ ] Review git diff --stat
[ ] Update .ctx/active-tasks.md status to Done
[ ] Move to .ctx/recent-changes.md
[ ] Commit per CLAUDE.md Commit Policy (manual: ask first · auto: commit when gate passes)
```

---

## Fixing a Bug

```
[ ] Create task: fix/{{TASK_PREFIX}}xxx-short-description
[ ] Investigate ROOT CAUSE — not the symptom. Ask "why does this happen?" not "how to suppress this?"
[ ] Trace the full call chain — don't just patch where the error appears
[ ] Check if same pattern exists elsewhere in the affected area
[ ] Fix ALL related occurrences (not just the reported symptom)
[ ] Assess blast radius — what else could break from this fix?
[ ] Build / compile — verify no errors
[ ] Test — run tests if available, or manual verification
[ ] Update docs affected by the fix (API.md, README, CLAUDE.md if commands changed)
[ ] Review git diff --stat — ensure only relevant files changed
[ ] Summarize root cause + what was fixed + blast radius
[ ] Commit ONCE with all fixes, per CLAUDE.md Commit Policy (manual: ask first · auto: commit when gate passes)
```

Key: **never commit a partial fix**. If fixing file A reveals file B also broken → fix both → commit once.
Key: **never patch symptoms** — if login fails, don't just reset the DB. Find WHY it fails (wrong hash? expired token? missing migration?).

---

## Refactoring

```
[ ] Create task: refactor/{{TASK_PREFIX}}xxx-description
[ ] Identify all files affected by the refactor
[ ] Make changes incrementally but commit as one unit
[ ] Ensure tests still pass after refactor
[ ] No behavior changes — refactor only
[ ] Review git diff --stat
[ ] Commit per CLAUDE.md Commit Policy (manual: ask first · auto: commit when gate passes)
```

---

## Schema / Database Change

```
[ ] Add/modify model or schema definition
[ ] Create migration files (for all supported DB drivers if applicable)
[ ] Update matching types on other layers (e.g., frontend types, API docs)
[ ] Run migrations in dev
[ ] Run tests
[ ] Run migration-related validation agents (if applicable)
```

---

## Adding Environment Variables

```
[ ] Update .env.example FIRST
[ ] Update README env table (if exists)
[ ] Update config loader / struct to read new var
[ ] Test with and without the var set
[ ] Document default behavior when var is empty
```

---

## Before Creating Endpoints / Routes

ALWAYS scan existing routes before creating new ones. Never create from memory.

```
# Go (Gin/Echo/Fiber)
grep -rn "router\.\|\.GET\|\.POST\|\.PUT\|\.DELETE\|\.PATCH" --include="*.go" | grep -v "_test.go" | grep -v vendor

# Node.js (Express/Fastify)
grep -rn "router\.\|app\.get\|app\.post\|app\.put\|app\.delete" --include="*.ts" --include="*.js" | grep -v node_modules

# PHP (Laravel)
grep -rn "Route::" --include="*.php" | grep -v vendor

# Python (FastAPI/Django)
grep -rn "@router\.\|@app\.\|path(\|url(" --include="*.py" | grep -v __pycache__
```

Then:
1. Check for similar/duplicate paths (e.g., `/auth` vs `/api/auth` vs `/login`)
2. Follow the existing naming convention (prefix, versioning, nesting)
3. If duplicate found → reuse or extend, never create parallel route

---

## Before Creating Components

ALWAYS scan existing components before creating new ones.

```
# Vue
find . -name "*.vue" -path "*/components/*" -not -path "*/node_modules/*" | sort

# React
find . -name "*.tsx" -path "*/components/*" -not -path "*/node_modules/*" | sort

# Check for similar component by function
grep -rn "export.*function\|export default\|defineComponent" --include="*.vue" --include="*.tsx" -l | xargs grep -l "{keyword}"
```

Then:
1. Check if a similar component already exists (search by function, not just name)
2. Reuse or extend existing — never duplicate
3. Base/UI components (Button, Card, Badge) should exist in `components/ui/` — never recreate

---

## When to Spawn Sub-Agents

Use sub-agents for independent, parallelizable work. Stay single-agent for sequential, context-dependent work.

| Scenario | Approach |
|----------|----------|
| Research/explore while working | Spawn Explore agent in background |
| Run tests while coding | Spawn test agent in background |
| Multiple independent files to create | Spawn agents in parallel |
| Sequential logic (fix → test → commit) | Do it yourself |
| Small task (< 3 files) | Do it yourself |
| Needs full project context | Do it yourself |

Rules:
- Always give agent a COMPLETE task description (it has no prior context)
- Never spawn agent for tasks that need the conversation history
- Use worktree isolation when agent writes code (prevents conflicts)
- Check agent results before using — don't blindly trust

---

## When to Use Worktrees

Use git worktrees when agents write code in parallel to avoid conflicts.

- Agent writes code → use `isolation: "worktree"`
- Agent only reads/researches → no worktree needed
- Multiple agents writing to same files → DO NOT parallelize, do sequentially

---

## Playwright / Browser Screenshots

Never save screenshots to project root. Always use `.playwright-mcp/` directory:

```bash
# Correct — contained in dedicated directory
filename: ".playwright-mcp/screenshot-name.png"

# Wrong — pollutes project root
filename: "screenshot.png"
filename: "tmp/screenshot.png"
```

---

## File Naming Convention

**Rules:**
- Use **lowercase + hyphens** for docs/scripts — never spaces or camelCase
- Include **scope/count** when relevant: `5providers`, `34slips`, `10docs`
- Include **phase/version** for chronological docs: `phase2-4`, `v2`
- **Numbered series** (01, 02...) for ordered sub-topics within a group
- **Paired files** share the same base name: `slip16.jpg` + `slip16.json` + `slip16-analysis.md`
- File name should answer: **what is this?** + **how big/which scope?** at a glance

**Bad:** `report.md`, `test.py`, `notes.md`, `benchmark-report.md`
**Good:** `benchmark-5providers-34slips.md`, `research-ark-03-image-optimization.md`

**Debug scripts** go in `debug-scripts/` with descriptive names:
```
debug-scripts/
├── debug-query-login-fail.sql
├── debug-payment-timeout-3apis.sh
└── debug-memory-leak-worker.go
```

---

## What to ALWAYS Do (Without Being Asked)

- **Update existing docs** when your changes affect them — this is critical:
  - Changed Makefile commands → update README, CLAUDE.md Dev Commands
  - Changed API endpoints → update API docs
  - Changed architecture → update project-reference.md
  - Changed env vars → update .env.example first
  - Changed protocol/data format → update relevant docs
- **Update .ctx/active-tasks.md** and `.ctx/recent-changes.md` as part of task lifecycle
- **Update .ctx/learned.md** when you discover a new gotcha

---

## Analyzing Requirements

Before implementing what user asks, think critically:

1. **Understand the real need** — "add OAuth" might mean "users want faster login", which has multiple solutions
2. **Assess trade-offs** — if the request conflicts with security, performance, or existing architecture, say so
3. **Propose alternatives** — if there's a better way, present options:
   ```
   You asked for X. I can do that, but consider:
   - Option A: X as requested — {pros/cons}
   - Option B: Y instead — {pros/cons}
   Which do you prefer?
   ```
4. **Check blast radius** — will this change break other parts of the system?
5. **Don't blindly execute** — if something seems wrong or risky, ask before proceeding

---

## Roadmap & Ideas — Future Work Tracking

When user defers work ("do it later", "plan this", "just note it down"), add to `TODO.md`:

| User intent | Section | Format |
|------------|---------|--------|
| "do later" / "plan this" / "not now" | **Roadmap** | `- 📋 {description}` |
| "just an idea" / "not sure yet" / "maybe" | **Ideas** | `- 💬 {description}` |
| "do it now" / "add task" | **Backlog section** | `- ⬜ **{TASK_PREFIX}xxx** {description}` |

- Roadmap/Ideas do NOT get task IDs — move to backlog when ready to execute
- Briefly confirm: "Added to Roadmap." or "Noted as idea."

---

## Gotchas

> Add project-specific gotchas to `.ctx/learned.md` so they persist.

- If a task grows beyond original scope, split into subtasks
- When in doubt about approach, ask user before spending time coding
