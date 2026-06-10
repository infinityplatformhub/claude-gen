#!/bin/sh
# claude-gen hook — Stop
# Enforces the MANDATORY status report. If the turn did real work (>= 2 tool calls)
# and the final message has no "-> next step" line, block the stop once so the agent
# writes the report. The arrow marker is language-agnostic (works for Thai/English).

INPUT=$(cat)

printf '%s' "$INPUT" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

# Never loop: if we already blocked once this stop, let it through.
if data.get('stop_hook_active'):
    sys.exit(0)

path = data.get('transcript_path', '')
if not path:
    sys.exit(0)

try:
    lines = open(path, encoding='utf-8').read().splitlines()
except Exception:
    sys.exit(0)

def is_real_user_prompt(msg):
    content = msg.get('content', '')
    if isinstance(content, str):
        return True
    if isinstance(content, list):
        return not any(b.get('type') == 'tool_result' for b in content if isinstance(b, dict))
    return False

# Walk the current turn: everything after the last genuine user prompt.
turn = []
for line in lines:
    try:
        e = json.loads(line)
    except Exception:
        continue
    if e.get('type') == 'user' and is_real_user_prompt(e.get('message', {})):
        turn = []
    elif e.get('type') in ('user', 'assistant'):
        turn.append(e)

tool_calls = 0
last_text = ''
for e in turn:
    if e.get('type') != 'assistant':
        continue
    content = e.get('message', {}).get('content', [])
    if not isinstance(content, list):
        continue
    texts = []
    for b in content:
        if not isinstance(b, dict):
            continue
        if b.get('type') == 'tool_use':
            tool_calls += 1
        elif b.get('type') == 'text':
            texts.append(b.get('text', ''))
    if texts:
        last_text = '\n'.join(texts)

# Q&A turns (little or no tool use) don't need a report.
if tool_calls < 2:
    sys.exit(0)

# Report present: a line near the end starting with the next-step arrow.
tail = [l.strip() for l in last_text.strip().splitlines()[-6:]]
if any(l.startswith(('→', '->')) for l in tail):
    sys.exit(0)

reason = (
    'MANDATORY status report is missing. Before ending, summarize in the '
    'conversation language per CLAUDE.md: (1) what happened/why, (2) what was '
    'done, (3) what is next — and end with a final line starting with \"→ \" '
    'stating the next step or what you are waiting for.'
)
print(json.dumps({'decision': 'block', 'reason': reason}))
" 2>/dev/null

exit 0
