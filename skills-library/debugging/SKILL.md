---
name: debugging
description: Structured debugging — root cause first. Systematic methodology for reproducing, isolating, and fixing bugs across any stack.
metadata:
  version: "1.0.0"
  domain: workflow
  triggers: bug, debug, error, crash, unexpected behavior, root cause, investigate, broken
  role: specialist
  scope: methodology
  output-format: markdown
---

# Structured Debugging

Systematic debugging methodology. Root cause first — never patch symptoms.

## Core Methodology

```
1. REPRODUCE  → Can you make the bug happen reliably?
2. ISOLATE    → What is the smallest input/path that triggers it?
3. IDENTIFY   → What is the actual root cause (not the symptom)?
4. FIX        → Fix the cause, not just the visible effect
5. VERIFY     → Confirm the fix AND check for related occurrences
6. PREVENT    → Add test/guard so it can't recur silently
```

## Phase 1 — Reproduce

Before touching code:

```
[ ] Can you reproduce it consistently?
[ ] What are the exact steps / input / state to trigger it?
[ ] Does it happen in all environments or just one?
[ ] When did it start? (check git log for recent changes)
[ ] Is there an error message, stack trace, or log entry?
```

If you cannot reproduce it → gather more data before proceeding. Never guess-fix.

## Phase 2 — Isolate

Narrow down the scope:

```
[ ] Binary search: comment out half the code path — which half breaks?
[ ] Minimal reproduction: strip away everything unrelated
[ ] Check inputs: log the exact values entering the failing function
[ ] Check boundaries: is this an off-by-one, nil/null, empty collection, or type mismatch?
[ ] Check timing: is this a race condition? Run with race detector / add delays
```

### Using git bisect

```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>
# Git checks out a midpoint — test it, then:
git bisect good   # or
git bisect bad
# Repeat until the culprit commit is found
git bisect reset
```

## Phase 3 — Identify Root Cause

Common root cause categories:

| Category | Symptoms | Check |
|----------|----------|-------|
| **Null/nil reference** | Panic, NPE, undefined property | Missing nil check, uninitialized variable |
| **Race condition** | Intermittent failures, data corruption | Shared mutable state, missing locks |
| **Off-by-one** | Wrong count, missing item, index error | Loop bounds, slice indices, length vs. capacity |
| **State mutation** | Works first time, breaks on second | Shared reference, missing deep copy |
| **Type mismatch** | Silent wrong behavior | Implicit conversion, wrong JSON tag, enum value |
| **Async ordering** | Works sometimes, fails sometimes | Missing await, wrong callback order, event timing |
| **Config / env** | Works locally, fails in deploy | Missing env var, different defaults, path differences |
| **Dependency** | Broke after update | Check changelog, breaking changes, version pinning |

## Phase 4 — Fix

```
[ ] Fix the ROOT CAUSE, not just the symptom
[ ] Check if the same pattern exists elsewhere in the codebase
[ ] Fix ALL related occurrences — one commit, not per-file
[ ] Ensure the fix doesn't introduce new issues
[ ] Keep the fix minimal — don't refactor while fixing
```

## Phase 5 — Verify

```
[ ] The original bug no longer reproduces
[ ] Existing tests still pass
[ ] No new regressions in related functionality
[ ] Edge cases work (empty input, max values, concurrent access)
```

## Phase 6 — Prevent

```
[ ] Write a test that fails WITHOUT the fix and passes WITH it
[ ] If it was a type/contract issue → add type checks or validation
[ ] If it was a race condition → add race detector to CI
[ ] Update .ctx/learned.md if the gotcha is project-specific
```

## Debugging Checklist (Quick Reference)

When stuck, work through this list:

1. Read the EXACT error message — what does it actually say?
2. Check the stack trace — what function called what?
3. Add logging at the entry point of the failing path
4. Check recent changes: `git log --oneline -10`
5. Check if it's environment-specific: different machine, DB, config?
6. Rubber duck: explain the expected vs. actual behavior out loud
7. Sleep on it — fresh eyes catch what tired eyes miss

## Anti-Patterns

- **Shotgun debugging** — changing random things hoping something works
- **Symptom patching** — adding `if err != nil { return nil }` without understanding why
- **Blame the framework** — it's almost always your code
- **Fix and forget** — no test means the bug will return
- **Debug in production** — reproduce locally first
