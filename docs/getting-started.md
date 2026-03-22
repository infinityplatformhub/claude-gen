# Getting Started

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed (`claude --version`)
- Git

---

## Option 1: Plugin Install (Recommended)

Works on all platforms including Windows.

From within Claude Code:
```
/plugin install infinityplatformhub/claude-gen
```

Then run:
```
/claude-gen-init
```

---

## Option 2: CLI Install

For Mac, Linux, WSL:

```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
```

What it does:
1. **Backs up** existing `.claude/`, `.ctx/`, `CLAUDE.md`, `TODO.md` to `.claude-backup/{timestamp}/`
2. **Downloads** the framework (shallow clone, auto-cleaned)
3. **Installs** commands, agents, skills library, bootstrap templates
4. **Seeds** `.ctx/` files (won't overwrite if they already exist)
5. **Updates** `.gitignore`

After install, open Claude Code and run:
```
/claude-gen-init
```

---

## Option 3: Manual Inject

If you prefer to keep the framework repo locally:

```bash
git clone https://github.com/infinityplatformhub/claude-gen.git /tmp/framework
/tmp/framework/scripts/inject.sh /path/to/your/project
```

`inject.sh` does the same as `install.sh` but without backup and without auto-download.

---

## Option 2: Use as Template

Best for new projects starting from scratch.

```bash
# Clone the framework as your new project
git clone https://github.com/infinityplatformhub/claude-gen.git my-new-project
cd my-new-project

# Remove framework git history, start fresh
rm -rf .git
git init

# Open in Claude Code
claude

# Run the init command
/claude-gen-init
```

---

## What /claude-gen-init Does

The init agent runs 9 phases automatically:

1. **Asks your language** — English, Thai, or other
2. **Reads your codebase** — README, package.json, go.mod, docker-compose, git history
3. **Detects your stack** — maps to one of 12 profiles (go-nuxt, python-fastapi, php-laravel, etc.)
4. **Confirms with you** — shows what it found, asks max 4 questions
5. **Copies relevant skills** — from library to active, based on your stack
6. **Generates custom skills** — architecture reference + workflow rules for your project
7. **Creates .ctx/ files** — active-tasks, recent-changes, learned, local
8. **Creates .claude/ rules** — task-tracking, dev-workflow, stack-specific rules
9. **Generates CLAUDE.md** — your project's system prompt

---

## After Init

Your project will have this structure:

```
your-project/
├── .ctx/                          Claude writes here freely
│   ├── active-tasks.md            current WIP
│   ├── recent-changes.md          completed tasks
│   ├── learned.md                 project gotchas
│   └── local.md                   machine-specific (gitignored)
├── .claude/
│   ├── commands/                  /claude-gen-init, /claude-gen-add-skill, /claude-gen-sync-skills
│   ├── agents/                    project-init-agent
│   ├── skills/
│   │   ├── _library/              all available skills
│   │   ├── golang-pro/            active skill for this project
│   │   └── ...
│   └── rules/
│       ├── task-tracking.md
│       ├── dev-workflow.md
│       └── go-backend.md          stack-specific
├── CLAUDE.md                      system prompt
├── TODO.md                        task backlog
└── ...your code
```

---

## Day-to-Day Usage

### Starting Work
Just tell Claude what you want to do. It will:
- Create a task automatically
- Track it in `.ctx/active-tasks.md`
- Work on it following the project's patterns

### Adding Skills Later
```
/claude-gen-add-skill react-expert
/claude-gen-add-skill vitest
```

### Updating Skills
```
/claude-gen-sync-skills
```
Checks upstream for newer versions, shows diff, asks before updating.

### Updating Framework
```
/claude-gen-update
```
Pulls latest framework version, patches TODO.md and .gitignore, preserves all project config.

### Checking Status
Claude reads `.ctx/active-tasks.md` and `.ctx/recent-changes.md` at the start of every session automatically (via @import in CLAUDE.md).
