---
name: contract-first-api
description: >-
  Make the API the single source of truth with self-serve docs, so humans and AI
  agents can onboard from just (base_url, token). Use when building or auditing an
  HTTP API's endpoint + docs surface, adding an AI-agent on-ramp (llms.txt +
  markdown handbook + OpenAPI), generating consumer types from the spec, or
  checking for docs / endpoint / role drift.
---

# Contract-First API + Single-Source Docs

The API is the single source of truth. Goal: anyone — a human or an AI agent — who
has only `(base_url, token)` can self-onboard and use the API without asking a person.

Adapt every rule to the host project's real stack (framework, paths, commands).
These are hard rules, not suggestions. Drop sections the project genuinely lacks
(e.g. no frontend → skip the frontend half of rule 2/3).

## Hard rules

1. **OpenAPI is generated from code, never hand-maintained.** Use an OpenAPI-first
   framework (Huma v2, FastAPI, tRPC-openapi, NestJS, …) so `/openapi.json` is
   derived from handlers. Every route in the router must appear in the spec. Every
   operation carries `operationId`, `summary`, a real description, tags, and typed errors.

2. **Docs live once, served everywhere.** Keep the handbook as markdown in ONE
   folder. The backend embeds + serves it; the frontend imports the same files. The
   same content copy-pasted into two places is a bug — refactor it.

3. **Consumer types are generated from the live spec.** Frontend types / API client
   regenerate from `/openapi.json` with one command. Never hand-write a type that can
   be derived from the spec.

4. **Discovery chain (progressive disclosure) exists and stays linked:**
   `/llms.txt` (public, no auth) → markdown handbook (`/…/docs/help`) → `/openapi.json`
   → browsable UI (`/docs`, e.g. Scalar / Swagger / Redoc). `/llms.txt` links to the
   other three.

5. **The role/permission matrix in docs matches the real guards.** The handbook has a
   capability × role matrix; spot-check ≥3 endpoints that the guard matches what's
   written. If they diverge, either the code or the doc is wrong — fix it.

6. **The handbook states the agent workflow:** discover (`/llms.txt`) → read handbook
   → read openapi → act → verify (read-back / audit), with a real example call for
   each main action.

## Pitfalls the handbook must always call out

timezone (UTC / RFC3339) · id overflow (BIGINT → string) · size limits + the error
code returned on overflow · regex / format of keys and identifiers · rate limits
(state clearly if there are none).

## Definition of Done

- [ ] `/openapi.json` covers every live route; every op has full metadata.
- [ ] One markdown handbook, referenced by both backend and frontend (no copies).
- [ ] `/llms.txt`, handbook, `/openapi.json`, `/docs` all reachable and linked.
- [ ] Consumer types regenerate from the spec with one command.
- [ ] Role matrix in docs matches enforced guards (spot-check ≥3 endpoints).
- [ ] An agent with `(base_url, token)` completes discover → act → verify without asking a human.

## Optional: drift test (makes "enforce" real)

Add a test that fails when: a router route is missing from `/openapi.json`, a
role-matrix entry has no matching guard (or vice versa), or the handbook references a
path absent from the spec.
