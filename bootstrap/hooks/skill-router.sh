#!/bin/sh
# claude-gen hook — UserPromptSubmit
# Skills are model-invoked; without a per-prompt nudge they rarely fire. This injects
# a one-line routing reminder (~60 tokens) into every prompt.
# {{SKILL_LIST}} is replaced at init with the project's actual skills + 2-4 word hints.

cat > /dev/null

printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Project skills — invoke via the Skill tool BEFORE starting a matching task: {{SKILL_LIST}}. Full routing table: CLAUDE.md > Skill Routing."}}'
exit 0
