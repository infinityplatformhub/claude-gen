---
name: claude-gen-add-skill
description: Add a skill from the library to this project.
             Usage: /claude-gen-add-skill [skill-name] or /claude-gen-add-skill to see available list.
---

## Steps

1. **No argument given** → read `_index.json`, list available skills not yet active:
   ```
   Available skills for your stack ({profile}):
     golang-pro     — Go 1.22+ goroutines, GORM        [cached]
     python-pro     — Python 3.12+ async, typing        [cached]
     ...
   Already active: debugging, docker, git-advanced
   ```

2. **Argument given** → find {skill}:
   - Check `.claude/skills/{skill}/` → already active? Skip.
   - Check `.claude/skills/_library/_cache/{skill}/` → cached? Copy to active.
   - Check `.claude/skills/_library/{skill}/` → local skill? Copy to active.
   - Not found locally? Check `_registry.json` → fetch from source.

3. **Fetching from registry** (when not in cache):
   ```bash
   # Read _registry.json for source repo + ref (commit SHA)
   # SHA cannot use --branch, so clone then checkout:
   git clone --depth 50 {repo} /tmp/skill-fetch
   cd /tmp/skill-fetch && git checkout {ref}
   # Copy the skill directory from {path} to cache
   ```

4. **Validate after fetch**:
   - SKILL.md exists
   - Count files matches `file_count` in `_registry.json`
   - All files listed in `files` array are present
   - If validation fails → report error, do NOT copy broken skill

5. **On network failure**:
   - Report: "Cannot fetch {skill} — network unavailable."
   - If skill exists in `_cache/`: "Using cached version from {fetched date}."
   - If not cached: "Skill not available offline. Try again when connected."

6. **Copy to active**:
   ```
   .claude/skills/_library/_cache/{skill}/ → .claude/skills/{skill}/
   ```

7. **Report**: "Added: {name} — {description}"
