# Changelog

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
