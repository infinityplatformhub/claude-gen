# Changelog

## v1.0 — 2026-03-22

Initial release.

- Hybrid registry + cache architecture for skills (pinned SHA, offline-ready)
- 18 curated skills (13 external + 5 local), 12 stack profiles, 7 stack rules
- One-liner installer: `curl | sh` with auto-backup of existing .claude/
- 9-phase auto-init agent with stack detection
- Task tracking, commit discipline, PM autonomy, pre-commit checklist
- Roadmap & Ideas sections in TODO.md for deferred work
- File naming conventions, TODO archiving, no-unsolicited-docs rules
- Progress display during /claude-gen-init with /exit recommendation
- `.claude/skills/_library/` gitignored (re-downloaded on install)
- Commands: /claude-gen-init, /claude-gen-update, /claude-gen-add-skill, /claude-gen-sync-skills
