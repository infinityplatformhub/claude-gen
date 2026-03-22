# Features

---

## 1. Autonomous Project Management

Claude ทำหน้าที่ Lead Engineer & PM — ไม่ใช่แค่ช่วย แต่ตัดสินใจและจัดการเอง

### Task Tracking

- **สร้าง task อัตโนมัติ** — บอกสิ่งที่อยากทำ Claude สร้าง task ทันที ไม่ต้องถาม
- **Task ID format** — configurable prefix: `T-101`, `TASK-101`, `#101`
- **Status tracking** — `.ctx/active-tasks.md` (max 5) + `TODO.md` (backlog ทั้งหมด)
- **History** — เสร็จแล้วย้ายไป `.ctx/recent-changes.md` อัตโนมัติ
- **Archiving** — `TODO.md` เกิน 20 completed → archive ไป `docs/changelog.md`
- **Roadmap** — "do it later" → `📋` in Roadmap section (no task ID, move to backlog when ready)
- **Ideas** — "just an idea" → `💬` in Ideas section (captured, not committed to)

```
Create → In Progress → Before Commit → Done → Archived
```

### PM Decisions (ทำเองไม่ต้องถาม)
- เมื่อไหร่จะ commit (PM ตัดสิน, user approve)
- จะแตก subtasks ยังไง
- จะ bundle changes ยังไง

### ต้องถาม User ก่อนเสมอ
- ลบไฟล์ หรือ database tables
- เปลี่ยน shared interfaces
- เพิ่ม environment variables
- Commit (ต้อง user approve ทุกครั้ง)

### Status Reports (บังคับ)

หลังทำงานเสร็จทุกครั้ง สรุปเป็นภาษาที่ตั้งค่าไว้:
1. **Context** — ต้องทำอะไร / มีปัญหาอะไร
2. **What was done** — วิธี, ผลลัพธ์, การตัดสินใจ
3. **Issues found** — ปัญหาที่เจอ (ข้ามได้ถ้าไม่มี)
4. **Next** — ขั้นตอนถัดไป (ข้ามได้ถ้าไม่มี)

---

## 2. Code Quality & Safety

### Commit Discipline

Claude **บังคับใช้** commit discipline — ไม่ใช่แค่ guideline แต่เป็น gate ที่ผ่านไม่ได้ถ้าไม่ครบ

| สถานการณ์ | กลยุทธ์ |
|----------|---------|
| Bug fix เล็ก (1-3 files) | แก้ให้ครบ → 1 commit |
| Bug แก้แล้วเจออีก | แก้ทั้งหมด → 1 commit |
| Feature เล็ก | Implement ครบ → 1 commit |
| Feature ใหญ่ | แตก subtasks → 1 commit ต่อ subtask |

**Pre-Commit Checklist (ต้องผ่านทุกข้อ):**
1. งานเสร็จครบ ไม่ใช่ WIP
2. User ยืนยันผลลัพธ์
3. Task ID tracked ใน `.ctx/active-tasks.md` + `TODO.md`
4. Commit message มี task ID: `feat(T-xxx): ...`
5. `git diff --stat` reviewed
6. Impact Rules satisfied
7. ไม่มี hardcoded secrets / debug logs

### Impact Rules

ป้องกัน drift ระหว่าง layers — "แก้ X แล้วต้องแก้ Y ด้วย" Claude enforce อัตโนมัติ

```markdown
| You Changed | MUST Also Update | Validation |
|-------------|-----------------|------------|
| backend/models/*.go | frontend/types/*.ts | Run type-checker |
| backend/handlers/*.go (new endpoint) | docs/API.md | Run api-validator |
```

กำหนดเองได้ต่อ project ใน CLAUDE.md ตอน init

### Security (via Sentry's security-review)

ตรวจจับช่องโหว่ที่ exploit ได้จริง ไม่ใช่แค่ theoretical — ใช้ confidence-based reporting:

| Confidence | Action |
|-----------|--------|
| HIGH | พบ pattern + attacker-controlled input → **รายงาน** |
| MEDIUM | พบ pattern แต่ไม่ชัวร์ → **หมายเหตุให้ตรวจ** |
| LOW | Theoretical → **ไม่รายงาน** |

ครอบคลุม: injection, XSS, SSRF, CSRF, auth, crypto, deserialization, file security, supply chain — พร้อม language guides สำหรับ Python และ JavaScript

---

## 3. Knowledge & Context System

### Context Management

Claude จำ context ข้าม session ได้ โดยไม่ทำให้ codebase รก

| Layer | ไฟล์ | อยู่รอด Context Compact? |
|-------|------|:----------------------:|
| System prompt | `CLAUDE.md` | ✅ |
| Local overrides | `CLAUDE.local.md` (gitignored) | ✅ |
| Task state | `.ctx/active-tasks.md` | ✅ (via @import) |
| Recent changes | `.ctx/recent-changes.md` | ✅ (via @import) |
| Shared knowledge | `.ctx/learned.md` | ✅ (via @import) |
| Local memory | `.ctx/local.md` (gitignored) | ✅ (via @import) |
| Full backlog | `TODO.md` | ❌ (อ่านเอง + อ่านหลัง compact) |

**ทำไม .ctx/ อยู่นอก .claude/?** — Claude เขียน .ctx/ ทุก session (update tasks, เพิ่ม gotchas) วางนอก .claude/ ไม่ต้อง permission prompt

### Skills Library

ให้ Claude รู้จัก stack ของ project อย่างลึก — ไม่ต้องอธิบายซ้ำ โหลดเฉพาะที่ใช้ ไม่กิน context เปล่า

**Progressive Loading:**
1. **Metadata** — ชื่อ + description อยู่ใน context เสมอ (~100 words)
2. **SKILL.md body** — โหลดเมื่อ skill trigger (~200-500 lines)
3. **References** — โหลดเฉพาะ topic ที่ต้องการ (ไม่จำกัดขนาด)

**Hybrid Registry + Cache:**
- **Cache-first** — skills อยู่ใน repo ใช้ offline ได้
- **Pinned SHA** — ล็อค version ไม่เปลี่ยนเอง
- **Validated** — จำนวนไฟล์ตรงกับ `_registry.json`
- **Updatable** — `/claude-gen-sync-skills` เช็ค upstream + update ด้วย approval

| ประเภท | ที่อยู่ | ตัวอย่าง |
|--------|-------|---------|
| External (community) | `_cache/` | golang-pro, nuxt, react-expert, security-audit |
| Local (self-authored) | root level | debugging, docker, git-advanced |

---

## 4. Project Setup

### 12 Stack Profiles

Auto-detect ตอน `/claude-gen-init` — เลือก skills + rules ให้อัตโนมัติ ไม่ต้อง config เอง

| Profile | Backend | Frontend | Key Skills |
|---------|---------|----------|-----------|
| `go-nuxt` | Go | Nuxt 3 | golang-pro, nuxt, vue, golang-testing |
| `go-react` | Go | React | golang-pro, react-expert, golang-testing |
| `go-api` | Go | — | golang-pro, golang-testing |
| `python-fastapi` | FastAPI | — | python-pro, fastapi-expert |
| `python-django` | Django | — | python-pro, django-expert |
| `php-laravel` | Laravel | — | php-pro, laravel-specialist |
| `php-api` | PHP API | — | php-pro |
| `php-react` | PHP | React | php-pro, laravel-specialist, react-expert |
| `nodejs-express` | Express | — | typescript-pro, vitest |
| `nodejs-nuxt` | Node.js | Nuxt 3 | typescript-pro, nuxt, vue, vitest |
| `nodejs-react` | Node.js | Next.js | typescript-pro, react-expert, nextjs-dev, vitest |
| `react-standalone` | BaaS | React | typescript-pro, react-expert, nextjs-dev, vitest |

ทุก profile รวม: git-advanced, debugging, docker, security-audit

### Auto-Init (/claude-gen-init)

9 phases อัตโนมัติ:

| Phase | สิ่งที่ทำ |
|-------|---------|
| 0 | ถามภาษาสำหรับสนทนา |
| 1 | อ่าน codebase ทั้งหมด (README, deps, git, docker) |
| 2 | แสดงสิ่งที่ detect ได้ ถามสูงสุด 4 คำถาม |
| 3 | เลือก + copy skills ตาม detected stack |
| 4 | สร้าง custom skills เฉพาะ project (arch + workflow) |
| 5 | สร้าง/merge .ctx/ files |
| 6 | สร้าง .claude/rules/ |
| 7 | สร้าง/merge CLAUDE.md |
| 8 | อัพเดท .gitignore |
| 9 | สรุปผล |

รองรับ 4 สถานการณ์:
- **Project ใหม่** — ถามเพิ่ม สร้าง skeleton
- **Project มีอยู่ ไม่มี framework** — อ่าน codebase เยอะ ถามน้อย
- **Project มี framework เก่า** — migrate paths, เก็บ custom content
- **มี CLAUDE.md ไม่มี .ctx/** — สร้าง .ctx/ + อัพเดท imports

### Commands

| Command | Description |
|---------|-------------|
| `/claude-gen-init` | Full project initialization + stack detection |
| `/claude-gen-update` | Update framework to latest (auto-patch TODO.md, .gitignore) |
| `/claude-gen-add-skill [name]` | Add skill (cache-first, fetch on miss, validate) |
| `/claude-gen-sync-skills` | Update skills from upstream + suggest new ones |

