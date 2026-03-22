#!/bin/sh
# POSIX sh only — no bash features

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${1:-.}"

echo "Injecting Claude Code Framework → $TARGET"

# Create directories
mkdir -p "$TARGET/.ctx"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude/skills/_library/_cache"
mkdir -p "$TARGET/.claude/rules"

# Copy commands + agents
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$TARGET/.claude/commands/" 2>/dev/null
cp "$FRAMEWORK_DIR/.claude/agents/"*.md   "$TARGET/.claude/agents/"  2>/dev/null

# Copy skills library (local skills + _cache + manifests)
cp -r "$FRAMEWORK_DIR/skills-library/." "$TARGET/.claude/skills/_library/"

# Copy bootstrap templates (for init-agent to use)
mkdir -p "$TARGET/.claude/bootstrap"
cp -r "$FRAMEWORK_DIR/bootstrap/." "$TARGET/.claude/bootstrap/"

# Seed .ctx/ if empty
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

# Patch TODO.md — add Roadmap/Ideas if missing
if [ -f "$TARGET/TODO.md" ]; then
  if ! grep -q "## Roadmap" "$TARGET/TODO.md"; then
    printf "\n---\n\n## Roadmap\n\n> No task ID yet — move to backlog sections above when ready to execute.\n\n_Empty_\n\n---\n\n## Ideas\n\n> Captured for future consideration. Not committed to.\n\n_Empty_\n" >> "$TARGET/TODO.md"
  fi
fi

# .gitignore
IGNORE="$TARGET/.gitignore"
ENTRIES=".ctx/local.md
.claude/settings.local.json
.claude/skills/_library/
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

# Summary
CACHED=$(find "$TARGET/.claude/skills/_library/_cache" -maxdepth 1 -type d | tail -n +2 | wc -l)
LOCAL=$(find "$TARGET/.claude/skills/_library" -maxdepth 1 -type d -not -name "_cache" | tail -n +2 | wc -l)

echo ""
echo "Done."
echo "  Skills cached : $CACHED (from community)"
echo "  Skills local  : $LOCAL (self-authored)"
echo ""
echo "Open Claude Code and run: /init-project"
