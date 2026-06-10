# Task Tracking Rules

> Enforced by CLAUDE.md + hooks. Every task follows this lifecycle exactly.

## Persist Terse, Report Verbose — the one rule above all others

Chat reports to the user can be as detailed as useful — they cost tokens once.
Anything WRITTEN to `.ctx/` or `TODO.md` is loaded into every future session —
it costs tokens forever. So:

- `.ctx/` + `TODO.md` entries = **one line each**. No paragraphs, ever.
- Full prose detail has exactly ONE home: `docs/changelog.md` (append-only archive, never auto-imported).
- Everything else is a pointer to it. Never duplicate the same task's prose in two files.
- Byte budgets below are **hook-enforced** — exceeding one blocks your next action until trimmed.

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

Add to BOTH files — one line each:

**`.ctx/active-tasks.md`:**
```markdown
- 🔄 **{{TASK_PREFIX}}xxx** Short title · goal in a few words · blockers: none
```

**`TODO.md`** (under correct area section):
```markdown
- 🔄 **{{TASK_PREFIX}}xxx** Short title
```

Branch name is derivable ({{TASK_PREFIX}}xxx → `feat/{{TASK_PREFIX}}xxx-short-title`) — don't record it.

### 2. During Work

- Work on one task at a time unless subtasks are truly parallel
- Update `.ctx/active-tasks.md` status if blocked (`🔄` → `❌` + blocker note on the same line)
- If scope grows → create subtask {{TASK_PREFIX}}xxx.1, don't expand silently

### 3. On Completion

Run through the CLAUDE.md **Commit Policy** gate. Every box must pass before committing
(in manual mode the final box is the user's explicit approval; in auto mode the gate replaces it).

Then update the three homes — one line each:

1. DELETE the task line from `.ctx/active-tasks.md`
2. ADD one line to `.ctx/recent-changes.md`: `- YYYY-MM-DD **{{TASK_PREFIX}}xxx** one-line summary`
3. Mark the TODO.md line `✅` (keep it one line — do NOT append prose)
4. If the task deserves detail (decisions, gotchas, migration notes) → append a section to `docs/changelog.md`

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

## Context File Budgets (hook-enforced)

| File | Budget | Format |
|------|--------|--------|
| `.ctx/active-tasks.md` | 2 KB | one line per task, max 5 tasks |
| `.ctx/recent-changes.md` | 3 KB | one line per entry, max 10 entries |
| `.ctx/learned.md` | 6 KB | one line per entry |
| `TODO.md` | 16 KB | one line per task |

The `ctx-budget` hook blocks your next action when a write pushes a file over budget —
trim immediately, don't defer.

### `.ctx/active-tasks.md`
- Max 5 active tasks. Completed → delete here + one-liner in recent-changes (same session)
- Survives context compaction via @import — this is the session primer, keep it pure WIP

### `.ctx/recent-changes.md`
- Max 10 one-line entries — delete oldest when adding
- Detail lives in `docs/changelog.md`, NOT here

### `.ctx/learned.md`
- One line per gotcha. General project knowledge only (e.g., "Go requires rebuild", "use pnpm not npm")
- File-specific gotchas (matter for 1-2 files) → path-scoped `.claude/rules/` instead
- Delete entries that stop being true — this file must earn its tokens

### `.ctx/local.md`
- Machine-specific scratchpad (gitignored). NOT auto-imported — read it on demand when
  local setup matters. Long recipes/snippets belong in a skill or docs, not here

---

## TODO.md Rules

Status icons:
- `⬜` Pending
- `🔄` In Progress
- `✅` Done
- `❌` Blocked

Never reorder Done tasks — append only at bottom of Done section.

### Keeping TODO.md Lean (16 KB budget, hook-enforced)

- **Every entry is ONE line** — including ✅ done entries. Prose detail → `docs/changelog.md`
- **✅ in backlog sections** — when a section accumulates >10 done one-liners, move them to
  the Completed section; when Completed exceeds 20, move oldest to `docs/changelog.md`
- **Archive format** in changelog: `## Week of YYYY-MM-DD` with bullet list of completed tasks
- **Never delete** — always archive to changelog before removing from TODO.md
- **No duplicate task IDs** — a task ID appears in exactly ONE section. Moving a task
  (backlog → roadmap, roadmap → backlog) means delete + re-add, never copy

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
- Committing — follow the CLAUDE.md **Commit Policy** (manual mode: ask "commit?" then STOP and wait for yes; auto mode: commit once the gate passes, no prompt)
- Pushing — ALWAYS ask first, in every mode

Never ask for:
- Creating tasks (just do it)
- Deciding commit scope/timing (PM decides; in manual mode the user still approves the commit itself)
- Opening subtasks when scope grows (just do it, inform user)
