#!/bin/sh
# Claude Code General Framework — One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/infinityplatformhub/claude-gen/main/install.sh | sh
# Or:    sh install.sh [target-dir]
#
# POSIX sh only — works on Mac, Linux, WSL

set -e

REPO="https://github.com/infinityplatformhub/claude-gen.git"
TARGET="${1:-.}"
TMPDIR="${TMPDIR:-/tmp}/claude-gen-$$"
BACKUP_DIR="$TARGET/.claude-backup"
NOW=$(date +%Y%m%d-%H%M%S)

# ─── Colors (if terminal supports it) ────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  GREEN='' YELLOW='' BLUE='' NC=''
fi

info()  { printf "${BLUE}[info]${NC}  %s\n" "$1"; }
warn()  { printf "${YELLOW}[warn]${NC}  %s\n" "$1"; }
ok()    { printf "${GREEN}[ok]${NC}    %s\n" "$1"; }

# ─── Preflight ────────────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || { echo "Error: git is required but not installed."; exit 1; }

info "Claude Code General Framework installer"
info "Target: $(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"
echo ""

# ─── Backup existing .claude/ and .ctx/ ───────────────────────────────
backup_made=0

if [ -d "$TARGET/.claude" ] || [ -d "$TARGET/.ctx" ] || [ -f "$TARGET/CLAUDE.md" ]; then
  info "Existing framework detected — backing up to .claude-backup/$NOW/"
  mkdir -p "$BACKUP_DIR/$NOW"

  if [ -d "$TARGET/.claude" ]; then
    cp -r "$TARGET/.claude" "$BACKUP_DIR/$NOW/.claude"
    ok "Backed up .claude/"
  fi

  if [ -d "$TARGET/.ctx" ]; then
    cp -r "$TARGET/.ctx" "$BACKUP_DIR/$NOW/.ctx"
    ok "Backed up .ctx/"
  fi

  if [ -f "$TARGET/CLAUDE.md" ]; then
    cp "$TARGET/CLAUDE.md" "$BACKUP_DIR/$NOW/CLAUDE.md"
    ok "Backed up CLAUDE.md"
  fi

  if [ -f "$TARGET/TODO.md" ]; then
    cp "$TARGET/TODO.md" "$BACKUP_DIR/$NOW/TODO.md"
    ok "Backed up TODO.md"
  fi

  backup_made=1
  echo ""
fi

# ─── Clone framework (shallow, temp) ─────────────────────────────────
info "Downloading framework..."
git clone --depth 1 --quiet "$REPO" "$TMPDIR"
ok "Downloaded"
echo ""

# ─── Create directories ──────────────────────────────────────────────
mkdir -p "$TARGET/.ctx"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude/skills/_library/_cache"
mkdir -p "$TARGET/.claude/rules"

# ─── Copy commands + agents ───────────────────────────────────────────
cp "$TMPDIR/.claude/commands/"*.md "$TARGET/.claude/commands/" 2>/dev/null
cp "$TMPDIR/.claude/agents/"*.md   "$TARGET/.claude/agents/"  2>/dev/null
ok "Commands + agents installed"

# ─── Copy skills library ─────────────────────────────────────────────
cp -r "$TMPDIR/skills-library/." "$TARGET/.claude/skills/_library/"
CACHED=$(find "$TARGET/.claude/skills/_library/_cache" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
LOCAL=$(find "$TARGET/.claude/skills/_library" -maxdepth 1 -type d -not -name "_cache" 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
ok "Skills installed ($CACHED cached + $LOCAL local)"

# ─── Copy bootstrap templates (for init-agent to use) ────────────────
mkdir -p "$TARGET/.claude/bootstrap"
cp -r "$TMPDIR/bootstrap/." "$TARGET/.claude/bootstrap/"
ok "Bootstrap templates installed"

# ─── Seed .ctx/ (only if files don't exist) ───────────────────────────
[ -f "$TARGET/.ctx/active-tasks.md" ] || \
  printf "# Active Tasks\n\n## In Progress\nNone\n\n## Blocked\nNone\n" \
    > "$TARGET/.ctx/active-tasks.md"

[ -f "$TARGET/.ctx/recent-changes.md" ] || \
  printf "# Recent Changes\n\nNo completed tasks yet.\n" \
    > "$TARGET/.ctx/recent-changes.md"

[ -f "$TARGET/.ctx/learned.md" ] || \
  printf "# Learned\n> Tricks and gotchas.\n" \
    > "$TARGET/.ctx/learned.md"

[ -f "$TARGET/.ctx/local.md" ] || \
  printf "# Local Memory\n> Gitignored. Machine-specific notes.\n" \
    > "$TARGET/.ctx/local.md"

ok ".ctx/ files ready"

# ─── Update .gitignore ───────────────────────────────────────────────
IGNORE="$TARGET/.gitignore"
ENTRIES=".ctx/local.md
.claude/settings.local.json
.claude/bootstrap/
.claude-backup/
CLAUDE.local.md"

if [ -f "$IGNORE" ]; then
  for entry in $ENTRIES; do
    grep -qF "$entry" "$IGNORE" || printf "%s\n" "$entry" >> "$IGNORE"
  done
else
  printf "# Claude Framework\n" > "$IGNORE"
  for entry in $ENTRIES; do
    printf "%s\n" "$entry" >> "$IGNORE"
  done
fi
ok ".gitignore updated"

# ─── Cleanup temp ─────────────────────────────────────────────────────
rm -rf "$TMPDIR"

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo "============================================"
ok "Claude Code Framework installed!"
echo "============================================"
echo ""
if [ "$backup_made" = "1" ]; then
  info "Backup saved: .claude-backup/$NOW/"
fi
echo ""
info "Next step: open Claude Code and run"
echo ""
echo "    /init-project"
echo ""
