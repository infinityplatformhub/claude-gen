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
[ ] Ask user to approve commit
```

---

## Fixing a Bug

```
[ ] Create task: fix/{{TASK_PREFIX}}xxx-short-description
[ ] Investigate root cause — read code, check logs, understand WHY it breaks
[ ] Check if same pattern exists elsewhere in the affected area
[ ] Fix ALL related occurrences (not just the reported symptom)
[ ] Build / compile — verify no errors
[ ] Test — run tests if available, or manual verification
[ ] Review git diff --stat — ensure only relevant files changed
[ ] Confirm with user: summarize what was wrong + what was fixed
[ ] User approves → commit ONCE with all fixes
```

Key: **never commit a partial fix**. If fixing file A reveals file B also broken → fix both → commit once.

---

## Refactoring

```
[ ] Create task: refactor/{{TASK_PREFIX}}xxx-description
[ ] Identify all files affected by the refactor
[ ] Make changes incrementally but commit as one unit
[ ] Ensure tests still pass after refactor
[ ] No behavior changes — refactor only
[ ] Review git diff --stat
[ ] Confirm with user → commit
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

## What NOT to Do (Without Being Asked)

- **Never create docs, reports, or analysis files** unless the user explicitly asks
- **Never create README, CHANGELOG, or API docs** as a side effect of other work
- **Never generate summaries or writeups** — report verbally in conversation instead
- **Never add comments, docstrings, or type annotations** to code you didn't change

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
> This section is for workflow-level gotchas only.

- Always check existing code before creating new files — avoid duplicates
- Never commit without user approval
- If a task grows beyond original scope, split into subtasks
- When in doubt about approach, ask user before spending time coding
