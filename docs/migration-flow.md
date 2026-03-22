# Migration Flow — การติดตั้งและไมเกรชั่น

---

## TL;DR

```
1. รัน install.sh   → ดาวน์โหลด framework + backup ของเก่า (ไม่แก้ CLAUDE.md)
2. รัน /init-project → detect stack + สร้าง/merge config (ไม่ลบของเดิม)
3. ทุกอย่าง backup อัตโนมัติ + รัน install ซ้ำกี่ครั้งก็ปลอดภัย
```

---

## Responsibility Split — ใครทำอะไร

| Action | install.sh | /init-project |
|--------|:---------:|:------------:|
| Download framework | ✅ | — |
| Backup ของเก่า | ✅ | — |
| ติดตั้ง commands/agents/skills | ✅ | — |
| สร้าง .ctx/ seed files | ✅ (ถ้ายังไม่มี) | — |
| อัพเดท .gitignore | ✅ | ✅ |
| วิเคราะห์ codebase | — | ✅ |
| ถาม user (ภาษา, prefix, ชื่อ) | — | ✅ |
| เลือก + copy skills ตาม stack | — | ✅ |
| สร้าง custom skills | — | ✅ |
| Merge .ctx/ files (ถ้ามีอยู่) | — | ✅ |
| สร้าง .claude/rules/ | — | ✅ |
| สร้าง/merge CLAUDE.md | — | ✅ |

**หลักคิด:** install.sh = วางโครงสร้าง, /init-project = configure ให้เข้ากับ project

---

## สถาปัตยกรรม

```
┌─────────────────────────────────────────────────┐
│              GitHub Repo (claude-gen)            │
│                                                 │
│  bootstrap/        skills-library/   .claude/   │
│  ├── CLAUDE.md.tmpl├── _index.json  ├── commands│
│  ├── TODO.md.tmpl  ├── _registry    ├── agents  │
│  └── rules/stacks/ ├── _cache/ (13) └── ...     │
│                    └── local (5)                │
└──────────────────┬──────────────────────────────┘
                   │  curl | sh
                   ▼
┌─────────────────────────────────────────────────┐
│              Target Project                      │
│                                                 │
│  .claude-backup/    ← ของเก่า (timestamp)        │
│  .claude/                                       │
│  ├── commands/      ← /init-project, /add-skill │
│  ├── agents/        ← project-init-agent        │
│  ├── bootstrap/     ← templates (gitignored)    │
│  ├── skills/                                    │
│  │   ├── _library/  ← read-only (ทุก skill)     │
│  │   └── {active}/  ← copy มาใช้จริง            │
│  └── rules/         ← project rules             │
│  .ctx/              ← เขียนได้ไม่ต้อง permission  │
│  CLAUDE.md          ← system prompt              │
│  TODO.md            ← task backlog               │
└─────────────────────────────────────────────────┘
```

---

## ขั้นตอนที่ 1: install.sh

```bash
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

### 1.1 Backup ของเก่า (อัตโนมัติ)

ถ้าพบ `.claude/`, `.ctx/`, หรือ `CLAUDE.md` → backup ไปที่ `.claude-backup/{timestamp}/`

```
.claude-backup/20260322-143022/
├── .claude/
│   ├── commands/       ← commands เก่า
│   ├── agents/         ← agents เก่า
│   ├── rules/          ← rules เก่า (รวม custom)
│   └── skills/         ← active skills เท่านั้น (ไม่รวม _library — ใหญ่เกิน)
├── .ctx/               ← context เก่าทั้งหมด
├── CLAUDE.md
└── TODO.md
```

### 1.2 ติดตั้ง framework

| สิ่งที่ copy | Overwrite? | หมายเหตุ |
|-------------|:---------:|----------|
| `.claude/commands/` | ✅ ทุกครั้ง | framework commands — ปกติไม่ต้องแก้เอง |
| `.claude/agents/` | ✅ ทุกครั้ง | framework agent — ปกติไม่ต้องแก้เอง |
| `.claude/skills/_library/` | ✅ ทุกครั้ง | re-download ใหม่เสมอ |
| `.claude/bootstrap/` | ✅ ทุกครั้ง | templates สำหรับ init-agent |
| `.ctx/*.md` | ❌ สร้างเฉพาะตอนไม่มี | ไม่แตะ content เดิม |
| `CLAUDE.md` | ❌ ไม่แตะ | ให้ /init-project จัดการ |
| `TODO.md` | ❌ ไม่แตะ | ให้ /init-project จัดการ |
| `.claude/rules/*` | ❌ ไม่แตะ | ให้ /init-project จัดการ |

---

## ขั้นตอนที่ 2: /init-project (9 Phases)

### Phase 0 — ถามภาษา

ถามครั้งเดียว ใช้ตลอด session — code/comments/commits ยังคงเป็นภาษาอังกฤษ

### Phase 1 — สำรวจ codebase

อ่าน README, package.json, go.mod, docker-compose, .env.example, git history → detect stack → map เป็น profile

### Phase 2 — ยืนยันกับ user (สูงสุด 4 คำถาม)

1. ชื่อ project
2. ENV prefix
3. Task ID prefix (default: `T-`)
4. มี tasks กำลังทำอยู่ไหม

### Phase 3 — เลือก + copy skills

```
สำหรับแต่ละ skill ที่ profile ต้องการ:

1. มีใน .claude/skills/{skill}/ แล้ว   → ข้าม
2. มีใน _library/_cache/{skill}/       → copy เข้า active
3. มีใน _library/{skill}/             → copy เข้า active
4. ไม่เจอเลย                          → fetch จาก registry (ต้อง network)
5. fetch ไม่ได้                        → ข้าม + แจ้งเตือน
```

### Phase 4 — สร้าง custom skills

สร้าง 2 SKILL.md เฉพาะ project:
- `{prefix}-workflow` — task format, commit format, impact rules
- `{project}-arch` — architecture จาก codebase จริง

### Phase 5 — .ctx/ files (merge ไม่ overwrite)

| ไฟล์ | ถ้ามีอยู่แล้ว | ถ้ายังไม่มี |
|------|-------------|-----------|
| active-tasks.md | **merge** — เก็บ tasks เดิม เพิ่ม header | สร้างใหม่ |
| recent-changes.md | **merge** — เก็บเดิม เพิ่ม git history | สร้างใหม่ |
| learned.md | **merge** — เก็บเดิม เพิ่ม gotchas | สร้างใหม่ |
| local.md | **ไม่แตะ** | สร้างใหม่ |
| TODO.md | **append** — ต่อท้าย | สร้างจาก template (includes Roadmap + Ideas sections) |

### Phase 6 — .claude/rules/

สร้าง/overwrite **เฉพาะ framework rules**:
- task-tracking.md (replace `{{TASK_PREFIX}}`)
- dev-workflow.md (replace `{{TASK_PREFIX}}`)
- project-reference.md (generate จาก codebase)
- {stack}.md (copy จาก template)

**Custom rules ของ user (เช่น `api-guidelines.md`) จะไม่ถูกลบ**

### Phase 7 — CLAUDE.md

```
if ไม่มี CLAUDE.md:
    สร้างใหม่จาก template → replace 6 placeholders → verify ไม่เหลือ {{...}}

elif มี CLAUDE.md แต่ไม่มี framework:
    ADDITIVE — เก็บ content เดิมทั้งหมด
    เพิ่ม framework sections ด้านบน (Role, Language, Status Report)
    เพิ่ม @-imports ด้านล่าง

elif มี CLAUDE.md + framework เก่า:
    UPDATE — แก้เฉพาะส่วนที่ outdated
    เก็บ custom sections
    อัพเดท @-imports ให้ชี้ .ctx/

elif มี CLAUDE.md แต่ไม่มี .ctx/:
    สร้าง .ctx/ + อัพเดท imports เท่านั้น
```

Placeholders (6 ตัว):

| Placeholder | มาจาก |
|-------------|--------|
| `{{PROJECT_NAME}}` | Phase 2 คำถาม 1 |
| `{{PROJECT_DESCRIPTION}}` | README.md หรือถาม user |
| `{{CONVO_LANG}}` | Phase 0 |
| `{{TASK_PREFIX}}` | Phase 2 คำถาม 3 |
| `{{STACK_SUMMARY}}` | Phase 1 detect |
| `{{IMPACT_RULES}}` | Generate จาก stack |

### Phase 8 — .gitignore

เพิ่ม entries ที่ยังไม่มี: `.ctx/local.md`, `.claude/settings.local.json`, `.claude/bootstrap/`, `.claude-backup/`, `CLAUDE.local.md`

### Phase 9 — รายงานสรุป (ภาษาที่เลือก)

---

## Failure Handling

### install.sh ล้มเหลว

- `trap cleanup EXIT` — ลบ temp dir เสมอ ไม่ว่าจะสำเร็จหรือไม่
- git clone fail → แสดง error + exit (ไม่ copy อะไรเลย)
- copy fail กลางทาง → backup ยังอยู่ รัน install ใหม่ได้

### /init-project ล้มเหลว

- Non-destructive — merge เท่านั้น ไม่ลบอะไร
- fail กลาง phase → ไฟล์ที่สร้างแล้วยังอยู่ รัน `/init-project` ใหม่ได้
- skill fetch fail → ข้าม + แจ้งเตือน ใช้ `/add-skill` ภายหลัง

---

## Idempotency — รันซ้ำได้ปลอดภัย

### install.sh

- รันซ้ำกี่ครั้งก็ได้ — backup ใหม่ทุกครั้ง (timestamp ไม่ซ้ำ)
- `.ctx/` ไม่ถูก overwrite (สร้างเฉพาะตอนไม่มี)
- commands/agents/skills/bootstrap overwrite ด้วย version ล่าสุดเสมอ

### /init-project

- รันซ้ำได้ — merge แทน overwrite
- skills ที่ active อยู่แล้ว → ข้าม
- CLAUDE.md ที่มี framework แล้ว → update เฉพาะส่วนที่ outdated
- custom rules ไม่ถูกลบ

---

## ตัวอย่าง: project Go + Nuxt ที่มี CLAUDE.md อยู่แล้ว

### ก่อนติดตั้ง

```
my-project/
├── CLAUDE.md              ← เขียน role ไว้เอง
├── .claude/rules/
│   └── api-guidelines.md  ← custom rule
└── ...code (Go + Nuxt)
```

### หลัง install.sh

```
my-project/
├── CLAUDE.md                    ← ยังเหมือนเดิม ไม่ถูกแก้
├── .claude/
│   ├── commands/                ← ใหม่ (init-project, add-skill, sync-skills)
│   ├── agents/                  ← ใหม่ (project-init-agent)
│   ├── bootstrap/               ← ใหม่ (templates)
│   ├── skills/_library/         ← ใหม่ (18 skills)
│   └── rules/
│       └── api-guidelines.md    ← ยังอยู่!
├── .ctx/                        ← ใหม่ (seed files)
├── .claude-backup/20260322/     ← backup ของเก่า
└── ...code
```

### หลัง /init-project

```
detected: go-nuxt
skills activated: golang-pro, golang-testing, nuxt, vue, migration-database,
                  docker, git-advanced, debugging, security-audit
custom skills: t-workflow, myproject-arch

CLAUDE.md: merged (เก็บ content เดิม + เพิ่ม framework sections + @-imports)
TODO.md: created from template
.ctx/: enriched with git history + detected gotchas
.claude/rules/: task-tracking, dev-workflow, project-reference, go-backend, vue-nuxt
                + api-guidelines.md ยังอยู่
```

---

## Restore จาก backup

```bash
# ดู backup ที่มี
ls .claude-backup/

# restore ไฟล์เฉพาะ
cp .claude-backup/20260322-143022/CLAUDE.md ./CLAUDE.md
cp .claude-backup/20260322-143022/.claude/rules/my-rule.md .claude/rules/

# restore ทั้ง folder
cp -r .claude-backup/20260322-143022/.ctx/ .ctx/
```

---

## ข้อควรระวัง

1. **Commands/agents ที่แก้เอง** → ถูก overwrite ทุกครั้งที่ install ใหม่ (backup มี แต่ต้อง restore เอง)
2. **_index.json ที่เพิ่ม custom profile** → ถูก overwrite ให้ restore จาก backup แล้วเพิ่มกลับ
3. **Backup สะสม** → ลบ `.claude-backup/` เก่าได้ตลอดเมื่อไม่ต้องการ
