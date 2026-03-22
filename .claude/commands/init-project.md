---
name: init-project
description: Alias for /claude-gen-init. Initialize claude-gen framework.
---

Read and follow the full initialization flow in `.claude/agents/project-init-agent.md`.

The agent runs 9 phases:
0. Ask user's preferred language
1. Discover — read codebase, git history, dependencies
2. Confirm — show detected stack, ask max 4 questions
3. Select & copy skills from library matching detected stack
4. Generate custom project-specific skills
5. Generate .ctx/ files (active-tasks, recent-changes, learned, local)
6. Generate .claude/ rules (task-tracking, dev-workflow, stack rules)
7. Generate or merge CLAUDE.md
8. Update .gitignore
9. Report summary

Start by reading `.claude/agents/project-init-agent.md`, then execute each phase in order.
