---
name: project-init-agent
description: Full project initialization. Reads codebase, detects stack,
             selects skills, generates framework files.
allowed-tools: Read, Write, Bash, Glob, Grep, LS
---

# Project Init Agent

## Phase 0 — Language Setup (First Thing)

Before doing anything else, ask the user ONE question:

"What language should I use when talking to you?
  1. English
  2. Thai (ภาษาไทย)
  3. Other: ___"

Store the answer as {LANG}. Use this language for ALL communication
throughout this session and generate all CLAUDE.md user-facing text in {LANG}.
Code, comments, commits, and docs always stay in English regardless.

---

## Phase 1 — Discover (Read Before Asking)

Read everything available before asking the user anything else.

### 1.1 Read existing files
- README.md → project name, description, stack hints
- package.json / go.mod / requirements.txt / Cargo.toml → dependencies
- docker-compose*.yml → services, ports, databases
- .env.example → environment variable patterns, naming conventions
- Makefile → available commands, build patterns
- CLAUDE.md (if exists) → already has framework? what version?

### 1.2 Analyze git
```bash
git remote -v 2>/dev/null                     # project name from remote
git log --oneline -20 2>/dev/null             # recent work patterns
git log --format="%s" -30 2>/dev/null | sort -u  # commit style
git ls-files 2>/dev/null | head -80           # file structure
git log --format="%an" -5 2>/dev/null | head -1  # primary author
```

### 1.3 Check existing framework state
```bash
ls -la .ctx/ 2>/dev/null
ls -la .claude/ 2>/dev/null
cat .ctx/active-tasks.md 2>/dev/null
```

### 1.4 Auto-detect stack
From files found, determine:
- Backend: Go / Python / Node.js / Ruby / Rust / other
- Framework: Gin / Fiber / Echo / FastAPI / Express / Rails / other
- Frontend: Nuxt / React / Vue / Next.js / none
- Database: MySQL / PostgreSQL / MongoDB / SQLite / none
- ORM/Migration: GORM / Prisma / SQLAlchemy / Alembic / other
- Infrastructure: Docker / K8s / bare metal

Map to stack_profile from _index.json.

---

## Phase 2 — Confirm (Minimal Questions)

Show auto-detected summary and ask ONLY what cannot be detected:

```
Here's what I found:

  Project : {name from git remote or folder}
  Stack   : {detected stack profile}
  Database: {detected DB}
  Status  : {new / existing without framework / existing with old framework}

I need a few more details:
  1. Human-readable project name: ___
  2. ENV variable prefix (e.g. APP_, MYAPP_, CPT_): ___
  3. Task ID prefix (e.g. T-, TASK-, #): ___  [default: T-]
  4. Any active tasks right now? (describe briefly or "none"): ___
```

Max 4 questions. If something can be inferred, infer it.

---

## Phase 3 — Select & Copy Skills

Find the skills library:
```bash
find . -name "_index.json" -path "*_library*" 2>/dev/null | head -1
```

Read `_index.json` → `stack_profiles[{detected_stack}].skills` list.

For each skill in list:
1. Check if `.claude/skills/{skill}/SKILL.md` already exists → skip
2. Look for skill in this order:
   a. `.claude/skills/_library/_cache/{skill}/` → external cached skill
   b. `.claude/skills/_library/{skill}/` → local self-authored skill
3. Copy entire skill directory (SKILL.md + references/) → `.claude/skills/{skill}/`
4. Validate: SKILL.md exists, check `_registry.json` file_count if external
5. Log result

If a skill is in `_index.json` but not found in library:
- Check `_registry.json` for source info
- If network available → fetch from source at pinned SHA
- If network unavailable → skip with warning, suggest `/sync-skills` later

---

## Phase 4 — Generate Custom Skills

Using skill-creator, generate 2 project-specific skills:

### {task-prefix}-workflow skill
Content: task tracking rules tailored to this project
- task ID format: {task-prefix}-xxx
- commit format with task ID
- impact rules specific to detected stack
- when to ask user

### {project-name}-arch skill
Content: architecture reference generated from actual codebase
- key interfaces/contracts that cannot change
- directory structure + what lives where
- detected patterns and conventions
- gotchas found during Phase 1

Write to: `.claude/skills/{name}/SKILL.md`

---

## Phase 5 — Generate .ctx/ Files

Write these WITHOUT permission prompt (outside .claude/):

### .ctx/active-tasks.md
```markdown
# Active Tasks — {project name}
> Current WIP. Max 5 active tasks.
> Full rules: .claude/rules/task-tracking.md

## In Progress
{if user mentioned active tasks in Phase 2 → create task entries}
{else → "None — project initializing"}

## Blocked
None
```

### .ctx/recent-changes.md
```markdown
# Recent Changes — {project name}
> Last completed tasks. Older entries → docs/CHANGELOG.md

{if existing project → summarize last 10 git commits as completed tasks}
{if new project → "No completed tasks yet."}
```

### .ctx/learned.md
```markdown
# Learned — {project name}
> Tricks, gotchas, project-specific knowledge. Shared via git.
> Machine-specific notes go in local.md (gitignored).

## Detected on init — {date}
{any patterns/gotchas found during Phase 1 codebase reading}
{e.g. "MySQL 8 requires parseTime=true in DSN"}
{e.g. "package.json uses pnpm, not npm"}
{if nothing notable → "Nothing notable yet."}
```

### .ctx/local.md (only if not exists)
```markdown
# Local Memory — Machine-specific
> Gitignored. Personal preferences and machine-specific notes.
```

### TODO.md
- If exists → append framework task section at bottom, do NOT overwrite
- If not exists → generate from bootstrap/TODO.md.tmpl with project values

---

## Phase 6 — Generate .claude/ Files

Inform user: "Writing to .claude/ — will ask for permission once."

Batch ALL .claude/ writes into one operation:

### .claude/rules/task-tracking.md
Copy from bootstrap/rules/task-tracking.md.
IMPORTANT: Replace ALL `{{TASK_PREFIX}}` with the user's chosen prefix (e.g., `T-`).
Search and replace globally — the file has 20+ occurrences.

### .claude/rules/dev-workflow.md
Copy from bootstrap/rules/dev-workflow.md.
Replace ALL `{{TASK_PREFIX}}` with the user's chosen prefix.

### .claude/rules/project-reference.md
Generate from codebase reading in Phase 1:
- ports and services detected
- key ENV variables found in .env.example
- directory structure summary
- interfaces/contracts that cannot change

### .claude/rules/{stack}.md
Copy from bootstrap/rules/stacks/{detected_stack}.md

---

## Phase 7 — Generate CLAUDE.md

### New project or no existing CLAUDE.md:
Generate from bootstrap/CLAUDE.md.tmpl with all values filled in.

### Existing CLAUDE.md (no framework):
- Read existing file entirely
- Preserve ALL existing content
- Add framework sections at top: Role, Language, Status Report, Task Workflow
- Add @-imports at bottom
- Inform user what was added

### Existing CLAUDE.md (old framework):
- Read existing file
- Detect what's outdated (missing .ctx/ imports, old paths, etc.)
- Update only outdated sections
- Preserve custom sections unchanged
- Show diff summary to user

---

## Phase 8 — Update .gitignore

Check .gitignore exists and has:
```
.ctx/local.md
.claude/settings.local.json
CLAUDE.local.md
```

Add missing entries. Create .gitignore if not exists.

---

## Phase 9 — Report

Print in {LANG}:

```
Framework initialized: {project name}

Stack profile : {profile}
Skills active : {list from Phase 3}
Custom skills : {list from Phase 4}
.ctx/ created : active-tasks, recent-changes, learned, local
.claude/ files: rules ({list}), skills ({list})
CLAUDE.md     : {created / updated / merged}

Manual steps needed:
  - Verify .gitignore includes .ctx/local.md
  - Set ENV prefix "{PREFIX}_" in your .env file
  - Check .ctx/active-tasks.md — add current tasks if any

Ready. Say what you want to work on, or use /{task-prefix-lowercase}-new to create a task.
```

---

## Handling Different Scenarios

### Scenario A: New empty project
- Infer name from folder name + ask to confirm
- Ask more questions (no files to read)
- Generate skeleton TODO.md from template

### Scenario B: Existing project, no framework
- Read codebase extensively in Phase 1
- Build recent-changes from last 10 git commits
- Generate architecture skill from actual code patterns
- Never overwrite existing code or non-framework files

### Scenario C: Existing project, has old framework
- Detect framework version from CLAUDE.md
- Migrate: move context/memory → .ctx/ if using old paths
- Update @-imports in CLAUDE.md
- Preserve all custom rules and task history

### Scenario D: Project with existing CLAUDE.md but no .ctx/
- Create .ctx/ files (safe, won't conflict)
- Update CLAUDE.md @-imports to point to .ctx/
- Keep everything else unchanged
