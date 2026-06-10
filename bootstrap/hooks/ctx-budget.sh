#!/bin/sh
# claude-gen hook — PostToolUse (Write|Edit)
# Enforces byte budgets on auto-imported context files. Count-based caps failed in
# practice (entries grew unbounded); bytes are the real cost, so bytes are the cap.
# Over budget -> block-feedback so the agent trims immediately, not "next time".

INPUT=$(cat)

FILE=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))
except Exception:
    pass
" 2>/dev/null)

[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

case "$FILE" in
  */.ctx/active-tasks.md)
    MAX=2048
    FIX="one line per task, max 5 tasks. Finished tasks become one-liners in recent-changes.md" ;;
  */.ctx/recent-changes.md)
    MAX=3072
    FIX="one line per entry (date + task ID + summary), max 10 entries. Older entries go to docs/changelog.md" ;;
  */.ctx/learned.md)
    MAX=6144
    FIX="1-line entries only. File-specific notes move to .claude/rules/, stale entries get deleted" ;;
  */TODO.md)
    MAX=16384
    FIX="done entries become one-liners, overflow moves to docs/changelog.md, duplicate task IDs get removed" ;;
  *) exit 0 ;;
esac

SIZE=$(wc -c < "$FILE" | tr -d ' ')
[ "$SIZE" -gt "$MAX" ] || exit 0

BASENAME=$(basename "$FILE")
printf '{"decision":"block","reason":"%s is %s bytes, over its %s-byte budget (it loads into every session). Trim it NOW before any other work: %s. Full detail belongs in docs/changelog.md only — context files hold one-liners and pointers."}\n' \
  "$BASENAME" "$SIZE" "$MAX" "$FIX"
exit 0
