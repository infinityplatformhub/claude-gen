---
name: project-init-agent
description: Full project initialization. Reads codebase, detects stack,
             selects skills, generates framework files.
allowed-tools: Read, Write, Bash, Glob, Grep, LS
---

# Project Init Agent

## Progress Display — MANDATORY

### After Phase 2 confirmation — show full plan ONCE (in {LANG}):

```
Setup Plan (9 steps):

  ✅ 1. Preferences → {LANG} · commit: {COMMIT_MODE} · auto-skill: {AUTO_SKILL}
  ✅ 2. Discover + confirm project details
  → 3. Copy skills for {profile}
  · 4. Generate custom skills (arch + workflow)
  · 5. Merge .ctx/ files
  · 6. Create .claude/rules/ + hooks + settings.json
  · 7. Generate/merge CLAUDE.md (commit policy + skill routing)
  · 8. Update .gitignore
  · 9. Report
```

Translate the plan labels to {LANG} at runtime (the example above is English).
If user chose Thai, display in Thai. If English, display in English.

### After that — just use section headers per phase:

```
## 3. Copy Skills

  ✓ golang-pro   (cache)
  ✓ nuxt         (cache)
  ...
```

Do NOT repeat the full plan on every phase. Just the heading + results.

---

## Phase 0 — Preferences (First Thing, Before ANY Discovery)

Every decision the user can make upfront is asked HERE — never saved for later phases.
Ask these 3 questions together in ONE message (this is the only English message allowed;
include short Thai hints so it's readable either way):

```
1. Language for our conversations?
     1. English   2. Thai (ภาษาไทย)   3. Other: ___

2. Commit mode?  [default: manual]
     • manual — I ask "commit?" and wait for your approval every time
     • auto   — I commit autonomously once work is complete + verified
                (pushing still ALWAYS asks, in both modes)

3. Auto-skill activation?  [default: yes]
     • yes — install a hook that surfaces the right skill on every prompt
     • no  — skills stay model-invoked only
```

Store as {LANG}, {COMMIT_MODE}, {AUTO_SKILL}.

### Language lock — read carefully

From the moment {LANG} is known, EVERY user-facing output switches to {LANG}:
every question, plan display, progress note, confirmation, and the final report.
Asking a follow-up question in English after the user chose Thai is a BUG — before
sending any message, check: "is this in {LANG}?" Only code, file contents, commit
messages, and docs stay in English.

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

## Phase 2 — Confirm (Minimal Questions, in {LANG})

Show auto-detected summary and ask ONLY what cannot be detected. The example below is
English — render the ENTIRE message (summary, labels, questions) in {LANG}:

```
Here's what I found:

  Project  : {name from git remote or folder}
  Stack(s) : {list all detected profiles, e.g. "go-api + php-laravel + react-standalone"}
  Database : {detected DB(s)}
  Status   : {new / existing without framework / existing with old framework}
  {if unmatched stacks: "Unmatched: Java (Spring) — no profile, will use universal skills"}

I need a few more details:
  1. Human-readable project name: ___  [suggest detected name as default]
  2. ENV variable prefix (e.g. APP_, MYAPP_, CPT_): ___  [suggest from .env.example if found]
  3. Task ID prefix (e.g. T-, TASK-, #): ___  [default: T-]
  4. Any active tasks right now? (describe briefly or "none"): ___
```

Ask only what cannot be inferred — offer a detected default for every question so the
user can answer "ok to all". Preferences ({LANG}, {COMMIT_MODE}, {AUTO_SKILL}) were
already collected in Phase 0 — NEVER re-ask them here.

### Question 5 — Contract-First API (ONLY if a backend/API was detected in Phase 1)

If Phase 1 found a backend or HTTP API (Go/FastAPI/Django/Express/NestJS/Laravel/…),
add ONE more question. Skip it entirely for frontend-only projects (e.g. react-standalone).
Render it in {LANG} — the example is English:

```
  5. Contract-First API? (API = single source of truth + self-serve docs)  [default: no]
       Makes the API self-documenting so humans AND AI agents can onboard from just
       (base_url, token): OpenAPI generated from code, one markdown handbook served
       everywhere, /llms.txt on-ramp, generated client types, docs↔guard drift test.
       • yes — install the contract-first-api skill + wire it into skill routing now.
               (The full build is run later on demand, or offered by /claude-gen-update.)
       • no  — skip; you can add it anytime with /claude-gen-add-skill contract-first-api
```

Store as {CONTRACT_FIRST} (yes/no). Default no if unanswered.

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

If {CONTRACT_FIRST} = yes:
  add contract-first-api to the merged skill list (source local, in skills-library/contract-first-api/)

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

All `.ctx/` files use ONE-LINE entries (byte budgets are hook-enforced — see
bootstrap/rules/task-tracking.md). If merging existing files that have verbose
multi-line entries, COMPRESS each to one line as part of the merge.

### .ctx/active-tasks.md (budget 2 KB)
- **If exists**: preserve tasks, compress each to one line. Add framework header if missing.
- **If not exists**: create fresh:
```markdown
# Active Tasks — {project name}
> One line per task, max 5. Budget 2 KB (hook-enforced). Rules: .claude/rules/task-tracking.md

## In Progress
{if user mentioned active tasks in Phase 2 → one line each: - 🔄 **T-xxx** title · goal · blockers: none}
{else → "None — project initializing"}

## Blocked
None
```

### .ctx/recent-changes.md (budget 3 KB)
- **If exists**: keep entries, compress each to one line, cap at 10.
- **If not exists**: create fresh:
```markdown
# Recent Changes — {project name}
> One line per entry, max 10. Older → docs/changelog.md

{if existing project → last 10 git commits, one line each: - YYYY-MM-DD summary}
{if new project → "No completed tasks yet."}
```

### .ctx/learned.md (budget 6 KB)
- **If exists**: keep entries, compress to one line each. Append "Detected on init" section.
- **If not exists**: create fresh:
```markdown
# Learned — {project name}
> One line per gotcha. Budget 6 KB. File-specific notes → .claude/rules/. Machine-specific → local.md

## Detected on init — {date}
{patterns/gotchas from Phase 1, one line each; if nothing → "Nothing notable yet."}
```

### .ctx/local.md (only if not exists)
```markdown
# Local Memory — Machine-specific
> Gitignored, NOT auto-imported. Read on demand. Long recipes belong in a skill, not here.
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

### .claude/hooks/ — enforcement scripts (ALWAYS deployed)

The framework's rules are hook-enforced, not memory-enforced. Deploy from
`.claude/bootstrap/hooks/`:

```bash
mkdir -p .claude/hooks
cp .claude/bootstrap/hooks/ctx-budget.sh   .claude/hooks/   # byte budgets on .ctx/ + TODO.md
cp .claude/bootstrap/hooks/report-guard.sh .claude/hooks/   # blocks ending a work turn without status report
chmod +x .claude/hooks/*.sh
```

If {AUTO_SKILL} = yes, also deploy the skill router:
1. Copy `.claude/bootstrap/hooks/skill-router.sh` → `.claude/hooks/skill-router.sh`
2. Replace `{{SKILL_LIST}}` in the copied file with the ACTUAL skill list resolved in
   Phases 3–4 (copied skills + the 2 custom skills). Comma-separated, each as
   `skill-name (2-4 word trigger hint)`. Keep it ONE line — this is injected every prompt,
   so it must stay ~60 tokens.
3. `chmod +x .claude/hooks/skill-router.sh`

### .claude/settings.json — hook wiring (ALWAYS)

1. **Read first** if the file exists — MERGE, never clobber existing keys/hooks.
   If old framework hooks exist (e.g., an inline-echo UserPromptSubmit skill reminder),
   replace just those.
2. Start from `.claude/bootstrap/hooks/settings.json.tmpl`. If {AUTO_SKILL} = no,
   drop the `UserPromptSubmit` block.
3. Validate after writing:
   - `python3 -m json.tool .claude/settings.json > /dev/null` (valid JSON)
   - run each hook script with sample stdin and confirm exit 0:
     `printf '{}' | .claude/hooks/ctx-budget.sh && printf 'x' | .claude/hooks/report-guard.sh`
   - if {AUTO_SKILL} = yes: `printf '{}' | .claude/hooks/skill-router.sh` emits valid JSON
     with `.hookSpecificOutput.additionalContext` and NO remaining `{{SKILL_LIST}}` placeholder.
4. `.claude/settings.json` + `.claude/hooks/` are committed (team-wide). Do NOT gitignore
   (only `settings.local.json` is ignored, per Phase 8).
5. **Watcher caveat** — settings.json created mid-session isn't picked up until the config
   reloads. Note in Phase 9 that the `/exit` + reopen step activates the hooks.

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
| `{{SKILL_ROUTING}}` | Fill per {AUTO_SKILL} — see **Skill Routing block** below |
| `{{COMMIT_POLICY}}` | Fill per {COMMIT_MODE} — see **Commit Policy block** below |

Verify NO `{{...}}` placeholders remain in the final CLAUDE.md.

### Skill Routing block (fills `{{SKILL_ROUTING}}`)

Build a markdown table mapping task type → skill, using the ACTUAL resolved skills
(Phases 3–4). One row per skill; the "when working on…" cell is a 3–8 word trigger.
Prepend this line (keep it whether or not the hook exists):

> Skills are **model-invoked**, not auto-run — invoke the matching skill via the Skill
> tool when a task fits.{if AUTO_SKILL=yes: " A UserPromptSubmit hook reinforces this each prompt."}

Example shape:

```
| When working on… | Invoke skill |
|------------------|--------------|
| Go backend — concurrency, services, idioms | `golang-pro` |
| DB migrations / schema / RLS | `migration-database` |
| Multi-tenant boundary, auth, OWASP review | `security-audit` |
| Starting / tracking / committing a task | `{task-prefix}-workflow` |
| Architecture, module boundaries, porting | `{project}-arch` |
```

If {CONTRACT_FIRST} = yes, add a row:
`| API endpoints, OpenAPI/docs, agent on-ramp | `contract-first-api` |`

If {AUTO_SKILL} = no, still emit the table (it's a passive nudge), just drop the hook sentence.

### Commit Policy block (fills `{{COMMIT_POLICY}}`)

Pick ONE block by {COMMIT_MODE}.

**If {COMMIT_MODE} = manual** (default — paste verbatim, sub `{{TASK_PREFIX}}`):

```
> Mode: **MANUAL** — never commit without explicit approval.

When work is complete, run the gate, then ask "commit?" and STOP — wait for the user to
reply "yes"/"commit". Asking is NOT approval. Pushing always needs separate approval.

Gate — do NOT commit until ALL checked:
1. [ ] Work COMPLETE — not partial/WIP
2. [ ] User explicitly approved ("yes"/"commit")
3. [ ] Task ID tracked (`.ctx/active-tasks.md` + `TODO.md`)
4. [ ] Message has task ID: `feat({{TASK_PREFIX}}xxx): ...`
5. [ ] `git diff --stat` reviewed — only intended files
6. [ ] Impact Rules satisfied
7. [ ] No duplicate routes/components; no hardcoded secrets; no debug logs
```

**If {COMMIT_MODE} = auto** (paste verbatim, sub `{{TASK_PREFIX}}`):

```
> Mode: **AUTO** — commit autonomously when the gate passes; no prompt needed.

The user has pre-approved committing. Commit once work is COMPLETE + verified — do not
ask. NEVER push without explicit approval. Never commit to "save progress".

Gate — commit only when ALL true (this replaces user approval):
1. [ ] Work COMPLETE — not partial/WIP
2. [ ] Builds/compiles clean; tests pass (if test infra exists)
3. [ ] Task ID tracked (`.ctx/active-tasks.md` + `TODO.md`)
4. [ ] `git diff --stat` reviewed — only intended files
5. [ ] Impact Rules satisfied
6. [ ] No hardcoded secrets, no debug logs left
If any box fails → keep working, do NOT commit.

Message quality — detailed but concise:
- Subject: `type({{TASK_PREFIX}}xxx): imperative summary` (≤ ~70 chars)
- Body (omit for trivial commits): 1–4 bullets covering WHAT changed + WHY. Capture the
  meaningful decisions; skip the obvious. No file-by-file narration.
- A reviewer should grasp intent without reading the diff.

Commit splitting — judgment, not one-size. Split by logical change, not by file/time:
- ONE commit when changes serve a single purpose (feature + its tests + docs; a fix + all
  its related occurrences; a wide refactor with one intent).
- SEPARATE commits when concerns are unrelated:
  · refactor/rename vs behavior change → refactor first, then feature
  · incidental bugfix found along the way → its own commit + its own task ID
  · schema/migration vs the code using it → often separate (migration revertable alone)
  · formatting/lint-only churn vs logic → separate so review stays clean
- Order prerequisites first (migration → model → handler → UI); each commit builds green.
- When unsure, prefer the fewest commits that each tell one coherent story and each
  build/pass on their own.
```

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
.playwright-mcp/
CLAUDE.local.md
```

Add missing entries. Create .gitignore if not exists.

### .dockerignore

If `.dockerignore` exists OR project has `Dockerfile`/`docker-compose*.yml`, ensure these entries exist:
```
.ctx/
.claude/
.claude-backup/
.playwright-mcp/
CLAUDE.md
CLAUDE.local.md
TODO.md
.git
```

Add missing entries. Create .dockerignore if Dockerfile exists but .dockerignore doesn't.

---

## Phase 9 — Report

Print summary in {LANG}. Example in English:

```
## 9. Done!

  Framework initialized: {project name}

  Stack       : {profile}
  Skills      : {count from Phase 3} + {count from Phase 4} custom
  Rules       : {count} + {preserved count} preserved
  Hooks       : ctx-budget (token budgets) + report-guard (status reports){if AUTO_SKILL=yes: + skill-router}
  CLAUDE      : {created / updated / merged}
  Skill-auto  : {on → routing table + skill-router hook | off → routing table only}
  Commit mode : {manual → asks first | auto → commits when gate passes}

  Please verify:
    - .ctx/active-tasks.md — tasks are correct
    - CLAUDE.md — existing content preserved + Commit Policy matches your choice
    - .claude/settings.json + .claude/hooks/ — hooks wired
    {if Scenario C: - Old .claude/context/ and .claude/memory/ have been removed}

  ⚠️ Important: type /exit then reopen claude
  so the new CLAUDE.md, rules, skills, and hooks are loaded into the session.
  Hooks only activate after this reload.
```

Translate to {LANG} at runtime.

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
  Inform user (in {LANG}): "Removed old .claude/context/ and .claude/memory/ directories"

### Scenario D: Project with existing CLAUDE.md but no .ctx/
- Create .ctx/ files (safe, won't conflict)
- Update CLAUDE.md @-imports to point to .ctx/
- Keep everything else unchanged
