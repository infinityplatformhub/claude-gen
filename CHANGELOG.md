# Changelog

## v3.2 — 2026-07-22

- **Removed `report-guard.sh` (Stop hook)** — it blocked ending a work turn without a
  `→ next step` line and interrupted normal use. Script deleted, `Stop` wiring dropped from
  the settings template, `{REPORT_GUARD}` init question removed. Status reports stay a
  CLAUDE.md guideline (no `→ ` marker rule). `/claude-gen-update` removes it from existing
  projects automatically, touching only the `Stop` block that points at `report-guard.sh`.
- **Added optional `codebase-memory` integration** — init Phase 0 offers it (with an
  explanation of what it is and its cost) as `no` / `global` / `project`; `/claude-gen-update`
  asks only when it isn't installed yet, otherwise refreshes the repo index. Optional by
  design: an install failure never aborts init/update.

## v3.0 — 2026-06-10

Theme: rules enforced by hooks, not agent memory. Token budgets on everything auto-imported.

- **Enforcement hooks** (`bootstrap/hooks/`, deployed to `.claude/hooks/` on init/update):
  - `ctx-budget.sh` (PostToolUse) — byte budgets on auto-imported files: active-tasks 2 KB,
    recent-changes 3 KB, learned 6 KB, TODO.md 16 KB. Over budget → blocks until trimmed.
  - `report-guard.sh` (Stop) — a work turn (≥2 tool calls) cannot end without a status
    report closing with a `→ next-step` line. Blocks once, never loops.
  - `skill-router.sh` (UserPromptSubmit) — replaces the v1.1 inline-echo hook with a real
    script embedding the project's skill list (~60 tokens/prompt).
- **Byte-caps replace count-caps** — caps on entry counts failed in practice (entries grew
  unbounded); the real cost is bytes/tokens, so budgets are now bytes, hook-enforced.
- **One-line entry format everywhere** — `.ctx/` + TODO.md entries are single lines; full
  prose detail has exactly one home (`docs/changelog.md`). "Persist terse, report verbose."
- **`.ctx/local.md` no longer auto-imported** — it's a machine-local scratchpad with low
  per-session relevance; read on demand.
- **CLAUDE.md template: Focus Discipline + Token Discipline sections** — one task at a time,
  unrelated findings become TODO one-liners, no drive-by fixes; status reports end with `→ `.
- **Init flow reordered** — Phase 0 asks ALL preferences upfront in one message (language,
  commit mode, auto-skill), then locks every subsequent message to the chosen language
  (mixed-language follow-ups after choosing Thai was a recurring bug). Phase 2 questions
  all ship with detected defaults so "ok to all" works.
- **`/claude-gen-update`** — deploys/refreshes hooks, migrates the old inline-echo skill
  hook, refreshes framework-owned rules (task-tracking, dev-workflow) so byte budgets reach
  existing projects, and patches CLAUDE.md (local.md import removal, new sections, `→ `
  report marker, `<!-- claude-gen v3 -->` version marker).
- **Update cleanup step** — over-budget `.ctx/` + TODO.md files are compressed immediately
  during update (archive prose to changelog → rewrite as one-liners), not left for the
  hook to catch mid-task.

## v1.1 — 2026-05-30

- **Init prompt: auto-skill activation** — opt-in during `/claude-gen-init`. Adds a Skill
  Routing table to CLAUDE.md plus a `UserPromptSubmit` hook in `.claude/settings.json` that
  surfaces the project's skills every prompt (skills are model-invoked, so this raises the
  odds the right one fires).
- **Init prompt: commit mode (manual | auto)** — opt-in during init.
  - `manual` (default) — preserves prior behavior: ask "commit?" and wait for approval.
  - `auto` — Claude commits autonomously once the gate passes (build/test green), writes
    detailed-but-concise messages, and splits commits by logical change (bundle vs split by
    judgment). Pushing still always asks.
- CLAUDE.md template: `## Pre-Commit Checklist` replaced by a mode-aware `## Commit Policy`
  block + new `## Skill Routing` section. New placeholders `{{COMMIT_POLICY}}`, `{{SKILL_ROUTING}}`.
- Bootstrap rules + `/claude-gen-update` now defer commit behavior to the single Commit
  Policy source and preserve a user's chosen mode on update.

## v1.0 — 2026-03-22

Initial release.

- Hybrid registry + cache architecture for skills (pinned SHA, offline-ready)
- 18 curated skills (13 external + 5 local), 12 stack profiles, 7 stack rules
- Plugin install: `/plugin install infinityplatformhub/claude-gen` (all platforms)
- CLI installer: `curl | sh` with auto-backup (Mac/Linux/WSL)
- 9-phase auto-init agent with stack detection
- Task tracking, commit discipline, PM autonomy, pre-commit checklist
- Roadmap & Ideas sections in TODO.md for deferred work
- File naming conventions, TODO archiving, no-unsolicited-docs rules
- Progress display during /claude-gen-init with /exit recommendation
- `.claude/skills/_library/` gitignored (re-downloaded on install)
- Commands: /claude-gen-init, /claude-gen-update, /claude-gen-add-skill, /claude-gen-sync-skills
