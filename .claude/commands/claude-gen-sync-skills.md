---
name: claude-gen-sync-skills
description: Update active skills from library. Check for new relevant skills.
             Fetches latest versions from registry sources.
---

## Steps

### 1. List current state
- Active skills in `.claude/skills/` (exclude `_library`)
- Cached skills in `.claude/skills/_library/_cache/`
- Local skills in `.claude/skills/_library/` (self-authored)

### 2. Check registry for updates
Read `_registry.json`. For each cached skill:
```bash
# Check if source repo has newer commits
git ls-remote {repo} HEAD
```

Compare remote HEAD with pinned `ref` in registry:
- **Same** → "Up to date"
- **Different** → "Update available: {skill} ({old_ref} → {new_ref})"

### 3. Fetch updates (with user approval)
For each skill with update available:
```
Update available:
  golang-pro     — 3bf9a24 → abc1234 (Jeffallan/claude-skills)
  security-audit — d2541c0 → def5678 (getsentry/skills)

Update these skills? [y/n]
```

On approval:
- Clone/fetch from source at new ref
- Validate: file count matches, all listed files present
- Replace cached version
- Update `_registry.json` with new ref + fetched date
- If skill is active → update active copy too

### 4. On network failure
```
Cannot reach {repo} — using cached version.
Cached skills are still functional. Try /claude-gen-sync-skills when connected.
```

### 5. Re-detect stack and suggest new skills
- Read CLAUDE.md or detect stack from codebase
- Check `_index.json` for skills matching stack but not yet active
- Report:
  ```
  Updated: golang-pro, security-audit
  Up to date: nuxt, vue, python-pro

  New skills available for your stack (go-nuxt):
    golang-testing — Go testing, testcontainers, mocks

  Activate new skills? [list]
  ```

### 6. Validate all active skills
After sync, verify every active skill:
- SKILL.md exists and is readable
- Referenced files (references/, languages/, etc.) are present
- Report any broken skills
