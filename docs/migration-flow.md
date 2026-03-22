# Migration Flow — การติดตั้งและไมเกรชั่น

เอกสารนี้อธิบายขั้นตอนทั้งหมดที่เกิดขึ้นเมื่อติดตั้ง framework ลงใน project

---

## สถาปัตยกรรม (Architecture)

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Repo                           │
│              infinityplatformhub/claude-gen              │
│                                                         │
│  bootstrap/          skills-library/     .claude/        │
│  ├── CLAUDE.md.tmpl  ├── _index.json    ├── commands/   │
│  ├── TODO.md.tmpl    ├── _registry.json ├── agents/     │
│  └── rules/          ├── _cache/ (13)   └── ...         │
│      └── stacks/     └── local (5)                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     │  curl | sh  หรือ  inject.sh
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    Target Project                        │
│                                                         │
│  .claude-backup/{timestamp}/    ← backup ของเก่า        │
│                                                         │
│  .claude/                                               │
│  ├── commands/      ← /init-project, /add-skill, ...   │
│  ├── agents/        ← project-init-agent               │
│  ├── bootstrap/     ← templates (gitignored)           │
│  ├── skills/                                            │
│  │   ├── _library/  ← skills ทั้งหมด (read-only)       │
│  │   └── {active}/  ← skills ที่ใช้จริง (copy มา)      │
│  └── rules/         ← rules ของ project                │
│                                                         │
│  .ctx/              ← context (เขียนได้ไม่ต้อง permission)│
│  ├── active-tasks.md                                    │
│  ├── recent-changes.md                                  │
│  ├── learned.md                                         │
│  └── local.md       ← gitignored                       │
│                                                         │
│  CLAUDE.md          ← system prompt (gen จาก template)  │
│  TODO.md            ← task backlog                      │
└─────────────────────────────────────────────────────────┘
```

---

## Flow ทั้งหมด

### ขั้นตอนที่ 1: install.sh (หรือ inject.sh)

```
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

#### 1.1 ตรวจสอบของเก่า

ตรวจว่ามี `.claude/`, `.ctx/`, `CLAUDE.md` อยู่แล้วหรือไม่

- **ไม่มี** → ข้ามไป step 1.2
- **มี** → backup ทั้งหมดไปที่ `.claude-backup/{timestamp}/`

#### 1.2 Backup (เฉพาะ install.sh)

```
.claude-backup/20260322-143022/
├── .claude/
│   ├── commands/         ← backup commands เก่า
│   ├── agents/           ← backup agents เก่า
│   ├── rules/            ← backup rules เก่า (รวม custom rules)
│   └── skills/           ← backup active skills (ไม่รวม _library — ใหญ่เกินไป)
├── .ctx/
│   ├── active-tasks.md   ← backup tasks เก่า
│   ├── learned.md        ← backup gotchas เก่า
│   └── ...
├── CLAUDE.md             ← backup system prompt เก่า
└── TODO.md               ← backup backlog เก่า
```

**สำคัญ:** `_library/_cache/` (skills 13 ตัว) ไม่ถูก backup เพราะ re-download ได้ — ลดขนาด backup จาก ~2MB เหลือ ~68KB

#### 1.3 Download framework

```
git clone --depth 1 (shallow, temp)
          ↓
  /tmp/claude-gen-{pid}/
          ↓
  copy ไฟล์เข้า target
          ↓
  ลบ temp dir (trap cleanup)
```

#### 1.4 สิ่งที่ถูก copy

| สิ่งที่ copy | จากไหน | ไปไหน | Overwrite? |
|-------------|--------|-------|-----------|
| Commands (3 ไฟล์) | `.claude/commands/` | `.claude/commands/` | **ใช่** — ทับทุกครั้ง |
| Agent (1 ไฟล์) | `.claude/agents/` | `.claude/agents/` | **ใช่** — ทับทุกครั้ง |
| Skills library | `skills-library/` | `.claude/skills/_library/` | **ใช่** — ทับทุกครั้ง |
| Bootstrap templates | `bootstrap/` | `.claude/bootstrap/` | **ใช่** — ทับทุกครั้ง |

#### 1.5 สิ่งที่ไม่ถูกแตะ

| ไฟล์ | ทำอะไร |
|------|--------|
| `CLAUDE.md` | **ไม่แตะ** — install.sh ไม่สร้าง/แก้ไข |
| `TODO.md` | **ไม่แตะ** — install.sh ไม่สร้าง/แก้ไข |
| `.claude/rules/*` | **ไม่แตะ** — install.sh ไม่ copy rules |
| `.claude/skills/{active}/*` | **ไม่แตะ** — เฉพาะ _library ถูก overwrite |
| `.ctx/active-tasks.md` | **สร้างเฉพาะตอนไม่มี** — ถ้ามีอยู่แล้วไม่แตะ |
| `.ctx/learned.md` | **สร้างเฉพาะตอนไม่มี** |
| `.ctx/local.md` | **สร้างเฉพาะตอนไม่มี** |

#### 1.6 อัพเดท .gitignore

เพิ่ม entry ต่อไปนี้ (ถ้ายังไม่มี):
```
.ctx/local.md
.claude/settings.local.json
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md
```

---

### ขั้นตอนที่ 2: /init-project (9 Phases)

หลัง install เสร็จ user เปิด Claude Code แล้วพิมพ์ `/init-project`

#### Phase 0 — ถามภาษา

```
"What language should I use when talking to you?"
  1. English
  2. Thai (ภาษาไทย)
  3. Other: ___
```

เก็บคำตอบไว้ใช้ตลอด session

#### Phase 1 — สำรวจ Codebase

อ่านทุกอย่างก่อนถาม user:
- README.md, package.json, go.mod, requirements.txt
- docker-compose*.yml, .env.example, Makefile
- CLAUDE.md (มีอยู่แล้ว? framework version ไหน?)
- git remote, git log, git ls-files

ผลลัพธ์: รู้ว่า project ใช้ stack อะไร → map เป็น profile

#### Phase 2 — ยืนยันกับ user

แสดงสิ่งที่ detect ได้ ถาม **สูงสุด 4 คำถาม**:
1. ชื่อ project
2. ENV prefix (เช่น `APP_`)
3. Task ID prefix (เช่น `T-`)
4. มี tasks อะไรกำลังทำอยู่ไหม

#### Phase 3 — เลือก + copy skills

```
_index.json → stack_profiles["go-nuxt"].skills
  ↓
["golang-pro", "golang-testing", "nuxt", "vue", ...]
  ↓
สำหรับแต่ละ skill:
  1. มีอยู่ใน .claude/skills/{skill}/ แล้ว? → ข้าม
  2. หาใน _library/_cache/{skill}/ → found? copy เข้า active
  3. หาใน _library/{skill}/ → found? copy เข้า active
  4. ไม่เจอเลย → ดึงจาก registry (ต้อง network) หรือ skip + แจ้งเตือน
```

#### Phase 4 — สร้าง custom skills

สร้าง 2 skills เฉพาะ project:
- `{prefix}-workflow` — task tracking rules เฉพาะ project นี้
- `{project}-arch` — architecture reference จาก codebase จริง

#### Phase 5 — สร้าง/merge .ctx/ files

```
┌────────────────────┬──────────────────────────────────┐
│ ไฟล์               │ ถ้ามีอยู่แล้ว                      │
├────────────────────┼──────────────────────────────────┤
│ active-tasks.md    │ MERGE — เก็บ tasks เดิม เพิ่ม header│
│ recent-changes.md  │ MERGE — เก็บเดิม เพิ่ม git history │
│ learned.md         │ MERGE — เก็บเดิม เพิ่ม gotchas ใหม่│
│ local.md           │ ไม่แตะ — สร้างเฉพาะตอนไม่มี       │
├────────────────────┼──────────────────────────────────┤
│ TODO.md            │ APPEND — ต่อท้าย ไม่ overwrite    │
└────────────────────┴──────────────────────────────────┘
```

#### Phase 6 — สร้าง .claude/ rules

สร้าง/overwrite เฉพาะ framework rules:
- `task-tracking.md` ← จาก template + replace `{{TASK_PREFIX}}`
- `dev-workflow.md` ← จาก template + replace `{{TASK_PREFIX}}`
- `project-reference.md` ← generate จาก codebase
- `{stack}.md` ← จาก `bootstrap/rules/stacks/`

**Custom rules ของ user (เช่น `api-guidelines.md`) จะไม่ถูกลบ**

#### Phase 7 — สร้าง/merge CLAUDE.md

```
┌─────────────────────────────────┬────────────────────────────────┐
│ สถานการณ์                       │ วิธีจัดการ                      │
├─────────────────────────────────┼────────────────────────────────┤
│ ไม่มี CLAUDE.md                 │ สร้างใหม่จาก template           │
│                                 │ replace 6 placeholders          │
│                                 │ verify ไม่เหลือ {{...}}         │
├─────────────────────────────────┼────────────────────────────────┤
│ มี CLAUDE.md (ไม่มี framework)  │ ADDITIVE — เก็บ content เดิม   │
│                                 │ เพิ่ม framework sections ด้านบน │
│                                 │ เพิ่ม @-imports ด้านล่าง        │
├─────────────────────────────────┼────────────────────────────────┤
│ มี CLAUDE.md (framework เก่า)   │ UPDATE — แก้เฉพาะส่วนที่ outdated│
│                                 │ เก็บ custom sections            │
│                                 │ อัพเดท @-imports ให้ชี้ .ctx/   │
├─────────────────────────────────┼────────────────────────────────┤
│ มี CLAUDE.md แต่ไม่มี .ctx/     │ สร้าง .ctx/ + อัพเดท imports   │
│                                 │ ไม่แก้อย่างอื่น                 │
└─────────────────────────────────┴────────────────────────────────┘
```

Placeholders ที่ต้อง replace (6 ตัว):

| Placeholder | มาจาก |
|-------------|--------|
| `{{PROJECT_NAME}}` | Phase 2 คำถามที่ 1 |
| `{{PROJECT_DESCRIPTION}}` | README.md หรือถาม user |
| `{{CONVO_LANG}}` | Phase 0 ภาษาที่เลือก |
| `{{TASK_PREFIX}}` | Phase 2 คำถามที่ 3 (default: `T-`) |
| `{{STACK_SUMMARY}}` | Generate จาก stack ที่ detect ได้ |
| `{{IMPACT_RULES}}` | Generate จาก stack หรือใส่ตัวอย่าง |

#### Phase 8 — อัพเดท .gitignore

เพิ่ม entry ที่ยังไม่มี:
```
.ctx/local.md
.claude/settings.local.json
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md
```

#### Phase 9 — รายงานสรุป

แสดงผลเป็นภาษาที่เลือกใน Phase 0:
```
Framework initialized: {project name}

Stack profile : go-nuxt
Skills active : golang-pro, golang-testing, nuxt, vue, ...
Custom skills : t-workflow, myapp-arch
.ctx/ created : active-tasks, recent-changes, learned, local
CLAUDE.md     : created / merged / updated
```

---

## สรุปความปลอดภัยของข้อมูล

### ไม่มีอะไรหาย

| ข้อมูลของ user | install.sh | /init-project |
|---------------|-----------|---------------|
| CLAUDE.md (เขียนเอง) | backup + ไม่แตะ | merge (เก็บเดิม + เพิ่ม framework) |
| TODO.md | backup + ไม่แตะ | append (ต่อท้าย ไม่ overwrite) |
| .ctx/active-tasks.md | backup + ไม่แตะ (ถ้ามี) | merge (เก็บ tasks เดิม) |
| .ctx/learned.md | backup + ไม่แตะ (ถ้ามี) | merge (เก็บ notes เดิม + เพิ่ม) |
| .ctx/local.md | backup + ไม่แตะ | ไม่แตะ (สร้างเฉพาะตอนไม่มี) |
| .claude/rules/custom.md | backup + ไม่แตะ | ไม่ลบ (preserve custom rules) |
| .claude/skills/{active} | backup (ไม่รวม _library) | ข้าม (ถ้ามีอยู่แล้ว) |

### สิ่งที่ถูก overwrite ทุกครั้ง (แต่ backup ไว้แล้ว)

- `.claude/commands/*.md` — framework commands (ปกติไม่ต้องแก้)
- `.claude/agents/*.md` — framework agent (ปกติไม่ต้องแก้)
- `.claude/skills/_library/` — skills library ทั้งหมด (re-download ใหม่เสมอ)
- `.claude/bootstrap/` — templates (re-download ใหม่เสมอ)

### ถ้าต้องการ restore จาก backup

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

1. **Commands/agents ที่ user แก้เอง** — จะถูก overwrite ทุกครั้งที่ install ใหม่ ถ้าแก้ไขแล้วอย่าลืม backup
2. **_index.json ที่ user เพิ่ม custom profile** — จะถูก overwrite ให้ restore จาก backup แล้วเพิ่มกลับ
3. **Re-install ซ้ำหลายครั้ง** — backup เป็น timestamp ไม่ทับกัน แต่จะสะสม ลบ backup เก่าได้ตลอด
