---
name: project-init-agent
description: Full project initialization. Reads codebase, detects stack,
             selects skills, generates framework files.
allowed-tools: Read, Write, Bash, Glob, Grep, LS
---

# Project Init Agent

## Progress Display — MANDATORY

### After Phase 2 confirmation — show full plan ONCE:

```
Setup Plan (9 ขั้นตอน):

  ✅ 1. ถามภาษา → {LANG}
  ✅ 2. สำรวจ codebase → {profile} detected
  → 3. Copy skills ตาม {profile} profile
  · 4. สร้าง custom skills (arch + workflow)
  · 5. Merge .ctx/ files
  · 6. สร้าง .claude/rules/
  · 7. อัพเดท CLAUDE.md
  · 8. อัพเดท .gitignore
  · 9. สรุปผล
```

### After that — just use section headers per phase:

```
## 3. Copy Skills

  ✓ golang-pro   (cache)
  ✓ nuxt         (cache)
  ...
```

Do NOT repeat the full plan on every phase. Just the heading + results.

---

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

### 1.4 Auto-detect stack(s)

From files found, detect ALL languages/frameworks present:
- Backend(s): Go / Python / Node.js / PHP / Ruby / Rust / Java / other
- Framework(s): Gin / FastAPI / Django / Express / Laravel / Rails / Spring / other
- Frontend(s): Nuxt / React / Vue / Next.js / Angular / none
- Database(s): MySQL / PostgreSQL / MongoDB / SQLite / none
- Infrastructure: Docker / K8s / bare metal

**Multi-stack detection (mono repo):**
A project may have multiple stacks. Example: `go.mod` + `composer.json` + `package.json` = Go + PHP + Node.js

For each detected stack, find matching profile(s) in `_index.json`.
Collect ALL matching profiles — do not pick just one.

**Unknown stack:**
If a language/framework is detected but has NO matching profile in `_index.json`:
- Still include universal skills (git-advanced, debugging, docker, security-audit)
- Search `_library/_cache/` for skills whose name matches the language (e.g., `rust-engineer`, `java-architect`)
- If relevant skills found in cache → include them
- Note the unmatched stack in the report so user can `/claude-gen-add-skill` manually

---

## Phase 2 — Confirm (Minimal Questions)

Show auto-detected summary and ask ONLY what cannot be detected:

```
Here's what I found:

  Project  : {name from git remote or folder}
  Stack(s) : {list all detected profiles, e.g. "go-api + php-laravel + react-standalone"}
  Database : {detected DB(s)}
  Status   : {new / existing without framework / existing with old framework}
  {if unmatched stacks: "Unmatched: Java (Spring) — no profile, will use universal skills"}

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

**Build a merged skill list from ALL detected profiles:**

```
For each detected profile in _index.json:
  add profile.skills to merged list
  add profile.rules to merged rules list

Deduplicate — each skill/rule appears once even if multiple profiles include it.

If unmatched stacks detected:
  add universal skills (git-advanced, debugging, docker, security-audit)
  scan _library/_cache/ for skills matching the language name
  (e.g., detect Java → look for java-*, spring-* in cache)
```

For each skill in merged list:
1. Already in `.claude/skills/{skill}/` → skip
2. Found in `_library/_cache/{skill}/` → copy to active
3. Found in `_library/{skill}/` → copy to active
4. Not found → fetch from registry (if network), else skip + warn
5. Validate: SKILL.md exists
6. Log result

For each rule in merged rules list:
- Will be copied in Phase 6 — just collect the list here

**Fallback for unmatched stacks (no profile, no cached skill):**

If a detected language/framework has no skill at all, Claude must still be effective:
- Use Claude's built-in knowledge for that language (Claude already knows Ruby, Rust, Java, etc.)
- Generate a basic `{language}-conventions` custom skill in Phase 4 based on codebase patterns found
- Include the unmatched stack in the project-reference.md (Phase 6)
- Note in Phase 9 report: "No dedicated skill for {language} — using built-in knowledge + generated conventions"

The framework provides structure (tasks, commits, context). Claude provides the language expertise.
Not having a registered skill does NOT block initialization.

---

## Phase 4 — Generate Custom Skills

Generate 2 project-specific skills (write SKILL.md directly — no external tool needed):

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

**IMPORTANT: If .ctx/ files already exist, MERGE — do not overwrite.**

### .ctx/active-tasks.md
- **If exists**: read existing content. Preserve any active tasks. Add framework header if missing.
- **If not exists**: create fresh:
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
- **If exists**: keep existing entries. Append git history below if useful.
- **If not exists**: create fresh:
```markdown
# Recent Changes — {project name}
> Last completed tasks. Older entries → docs/CHANGELOG.md

{if existing project → summarize last 10 git commits as completed tasks}
{if new project → "No completed tasks yet."}
```

### .ctx/learned.md
- **If exists**: keep existing entries. Append "Detected on init" section at the bottom.
- **If not exists**: create fresh:
```markdown
# Learned — {project name}
> Tricks, gotchas, project-specific knowledge. Shared via git.
> Machine-specific notes go in local.md (gitignored).

## Detected on init — {date}
{any patterns/gotchas found during Phase 1 codebase reading}
{if nothing notable → "Nothing notable yet."}
```

### .ctx/local.md (only if not exists)
```markdown
# Local Memory — Machine-specific
> Gitignored. Personal preferences and machine-specific notes.
```

### TODO.md
- If exists → append framework task section at bottom, do NOT overwrite
- If not exists → generate from .claude/bootstrap/TODO.md.tmpl with project values

---

## Phase 6 — Generate .claude/ Files

Inform user: "Writing to .claude/ — will ask for permission once."

**IMPORTANT: Preserve any existing custom rules in `.claude/rules/`.**
If user has files like `api-guidelines.md` or `coding-standards.md`, do NOT delete them.
Only create/overwrite the framework rules listed below.

Batch ALL .claude/ writes into one operation:

### .claude/rules/task-tracking.md
Copy from .claude/bootstrap/rules/task-tracking.md.
IMPORTANT: Replace ALL `{{TASK_PREFIX}}` with the user's chosen prefix (e.g., `T-`).
Search and replace globally — the file has 20+ occurrences.

### .claude/rules/dev-workflow.md
Copy from .claude/bootstrap/rules/dev-workflow.md.
Replace ALL `{{TASK_PREFIX}}` with the user's chosen prefix.

### .claude/rules/project-reference.md
Generate from codebase reading in Phase 1:
- ports and services detected
- key ENV variables found in .env.example
- directory structure summary
- interfaces/contracts that cannot change

### .claude/rules/{stack}.md
Copy from .claude/bootstrap/rules/stacks/{detected_stack}.md

---

## Phase 7 — Generate CLAUDE.md

### New project or no existing CLAUDE.md:
Generate from .claude/bootstrap/CLAUDE.md.tmpl. Replace ALL placeholders:

| Placeholder | Source |
|-------------|--------|
| `{{PROJECT_NAME}}` | From Phase 2 question 1 |
| `{{PROJECT_DESCRIPTION}}` | From README.md or ask user |
| `{{CONVO_LANG}}` | From Phase 0 language choice |
| `{{TASK_PREFIX}}` | From Phase 2 question 3 (default: `T-`) |
| `{{STACK_SUMMARY}}` | Generate from detected stack (Phase 1) |
| `{{DEV_COMMANDS}}` | Generate from Makefile, package.json scripts, or detected tools. Include: build, test (all + single), lint, dev server. If none detected, generate sensible defaults for the stack |
| `{{IMPACT_RULES}}` | Generate full markdown table from detected stack. Example: `\| backend/models/*.go \| frontend/types/*.ts \| Run type-checker \|`. If new project, generate a placeholder table with column headers only |

Verify NO `{{...}}` placeholders remain in the final CLAUDE.md.

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

Check .gitignore exists and has ALL of these:
```
.ctx/local.md
.claude/settings.local.json
.claude/skills/_library/
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md
```

Add missing entries. Create .gitignore if not exists.

---

## Phase 9 — Report

Use heading `## 9. เสร็จแล้ว!` (or equivalent in {LANG}). Print summary:

```
## 9. เสร็จแล้ว!

  Framework initialized: {project name}

  Stack   : {profile}
  Skills  : {count from Phase 3} + {count from Phase 4} custom
  Rules   : {count} + {preserved count} preserved
  CLAUDE  : {created / updated / merged}

  สิ่งที่ควรตรวจ:
    - ตรวจ .ctx/active-tasks.md ว่า tasks ถูกต้อง
    - ตรวจ CLAUDE.md ว่า content เดิมยังอยู่ครบ
    {if Scenario C: - ลบ .claude/context/ และ .claude/memory/ ที่ไม่ใช้แล้ว}

  ⚠️ สำคัญ: พิมพ์ /exit แล้วเปิด claude ใหม่
  เพื่อให้ CLAUDE.md, rules, skills ที่เพิ่งสร้างถูก load เข้า session
  หลังจากนั้นพร้อมทำงานได้เลยครับ
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
- Migrate old paths if found:
  - `.claude/context/active-tasks.md` → `.ctx/active-tasks.md`
  - `.claude/context/recent-changes.md` → `.ctx/recent-changes.md`
  - `.claude/memory/learned.md` → `.ctx/learned.md`
  - `.claude/memory/local.md` → `.ctx/local.md`
- Update @-imports in CLAUDE.md to point to `.ctx/`
- Preserve all custom rules and task history
- After migration is complete, **delete old directories**:
  ```bash
  rm -rf .claude/context/ .claude/memory/
  ```
  Inform user: "ลบ .claude/context/ และ .claude/memory/ ที่ไม่ใช้แล้ว"

### Scenario D: Project with existing CLAUDE.md but no .ctx/
- Create .ctx/ files (safe, won't conflict)
- Update CLAUDE.md @-imports to point to .ctx/
- Keep everything else unchanged
