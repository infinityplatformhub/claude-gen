# Changelog

## v3.1 — 2026-07-03

- **Opt-in `contract-first-api` skill** — API as single source of truth: OpenAPI generated
  from code, one markdown handbook served everywhere, `/llms.txt` agent on-ramp, generated
  client types, docs↔guard drift test. Offered at init/update when a backend is detected;
  not auto-loaded by any profile. (19 skills total: 13 external + 6 local)
- **`report-guard` status-report hook is now opt-in** — new `{REPORT_GUARD}` preference at
  init (Phase 0); `/claude-gen-update` Step 4d toggles it on/off for existing projects.
  Status reports stay a CLAUDE.md guideline when the hook is off.
- **init** — Phase 2 adds a backend-conditional Contract-First API question; update Step 8b
  offers it to existing backend projects (install-only or build-now, with a review-supervised
  sub-agent fan-out option).

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
