# Task Tracking Rules

> Enforced by CLAUDE.md. Every task follows this lifecycle exactly.

---

## Task ID Format

```
{{TASK_PREFIX}}{number}        main task         {{TASK_PREFIX}}101
{{TASK_PREFIX}}{number}.{sub}  subtask           {{TASK_PREFIX}}101.1
```

### Numbering Areas (customize per project)

Define task numbering areas in TODO.md. Example:
- `{{TASK_PREFIX}}1xx` — Infrastructure / DevOps
- `{{TASK_PREFIX}}2xx` — Backend Core
- `{{TASK_PREFIX}}3xx` — API Layer
- `{{TASK_PREFIX}}4xx` — Frontend
- `{{TASK_PREFIX}}5xx` — Testing
- `{{TASK_PREFIX}}9xx` — DX / Framework / Docs

---

## Task Lifecycle

### 1. Create Task (before any code)

Add to BOTH files:

**`.ctx/active-tasks.md`:**
```markdown
### {{TASK_PREFIX}}xxx: Short title
- **Status**: In Progress
- **Branch**: feat/{{TASK_PREFIX}}xxx-short-name
- **Goal**: one sentence
- **Files**: list of files expected to change
- **Blockers**: none
```

**`TODO.md`** (under correct area section):
```markdown
- **{{TASK_PREFIX}}xxx** Short title
```

### 2. During Work

- Work on one task at a time unless subtasks are truly parallel
- Update `.ctx/active-tasks.md` status if blocked
- If scope grows → create subtask {{TASK_PREFIX}}xxx.1, don't expand silently

### 3. Before Commit

Run through CLAUDE.md Pre-commit Checklist. Every box must be checked.

Update `.ctx/active-tasks.md`:
```markdown
- **Status**: Done
- **Completed**: YYYY-MM-DD
- **Summary**: what was done in one line
```

Move to `.ctx/recent-changes.md` + mark TODO.md as done.

### 4. Commit Message

```
feat({{TASK_PREFIX}}xxx): add user authentication
fix({{TASK_PREFIX}}xxx): handle nil pointer in handler
refactor({{TASK_PREFIX}}xxx): extract router to separate package
docs({{TASK_PREFIX}}xxx): update API reference
chore({{TASK_PREFIX}}xxx): add database migration
```

Types: `feat` | `fix` | `refactor` | `docs` | `chore` | `test` | `perf`

---

## `.ctx/active-tasks.md` Rules

- Maximum 5 active tasks at once
- Completed tasks move to `.ctx/recent-changes.md` within same session
- Never delete from `.ctx/active-tasks.md` without moving to `.ctx/recent-changes.md`
- If context compacts: tasks survive via @import in CLAUDE.md

## `.ctx/recent-changes.md` Rules

- Maximum 15 entries — oldest entries get removed when adding new ones
- This file is auto-imported into context, so keeping it lean matters
- Older entries are preserved in `TODO.md` Completed section (and eventually `docs/changelog.md`)

## `.ctx/learned.md` Rules

- Maximum ~30 entries — this file is @imported into every session
- Keep entries short (1 line each) — not paragraphs
- File-specific gotchas that only matter for 1-2 files → move to path-scoped `.claude/rules/` instead
- General project gotchas stay here (e.g., "Go requires rebuild", "use pnpm not npm")

---

## TODO.md Rules

Status icons:
- `⬜` Pending
- `🔄` In Progress
- `✅` Done
- `❌` Blocked

Never reorder Done tasks — append only at bottom of Done section.

### Keeping TODO.md Lean

TODO.md grows over time. Keep it manageable:

- **Completed section** — max 20 entries. When it exceeds 20, move older entries to `docs/changelog.md` (create if not exists)
- **Archive format** in changelog: `## Week of YYYY-MM-DD` with bullet list of completed tasks
- **Active sections** — only pending + in-progress tasks stay in main sections
- **Never delete** — always archive to changelog before removing from TODO.md
- If TODO.md exceeds ~150 lines, proactively archive completed tasks

---

## Branch Naming

```
feat/{{TASK_PREFIX}}xxx-short-description
fix/{{TASK_PREFIX}}xxx-short-description
refactor/{{TASK_PREFIX}}xxx-short-description
```

---

## PM Task Autonomy

Claude as PM manages the full task lifecycle:

- **Create tasks proactively** — when user describes work, open task immediately (no need to ask "should I create a task?")
- **Decide commit timing** — PM judges when work is commit-worthy based on Commit Discipline rules in CLAUDE.md
- **Bundle or split** — small related changes → bundle into 1 commit; large feature → split into subtasks with their own commits
- **Never commit prematurely** — if work is half-done, in progress, or untested → keep working, don't commit

### Bug Fix Decision Flow

```
1. User reports bug or Claude discovers bug during work
2. Create task ({{TASK_PREFIX}}xxx) immediately
3. Investigate root cause — don't just fix the symptom
4. Check if the same bug pattern exists elsewhere in affected area
5. Fix ALL related occurrences
6. Verify fix works (build, test if available)
7. Confirm with user: summarize what was wrong + what was fixed
8. Commit once — not per-file, not per-fix
```

### "Done" Definition

A task is "Done" ONLY when ALL of these are true:
- Code compiles / builds without errors
- Changed behavior works correctly
- No regressions introduced
- Tests pass (if test infra exists)
- User has confirmed the result
- All Impact Rules satisfied (CLAUDE.md table)

"Code written" ≠ "Done". "Committed" ≠ "Done". Only verified + confirmed = Done.

---

## When to Ask User

Always ask before:
- Deleting files or database tables
- Changing shared interfaces (breaks all implementations)
- Adding new environment variables
- Any irreversible operation
- Committing (user must explicitly approve)

Never ask for:
- Creating tasks (just do it)
- Deciding commit scope/timing (PM decides, user approves)
- Opening subtasks when scope grows (just do it, inform user)
