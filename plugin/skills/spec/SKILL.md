---
name: spec
description: Feature spec — take ONE roadmap item of a pscaffold product to a reviewable spec (problem, user stories, modules, contract changes, verification points) in docs/specs/NNNN-slug/spec.md. Interviews only on the module decomposition and the verification points. Use after `new-project`, or on "spec <item>", "write the PRD for", "zoom into <roadmap item>".
argument-hint: "<roadmap item>"
---

# spec

One roadmap item in, one spec out. The brief and ADRs already settle problem, users and
architecture, so synthesize most of the spec silently and ask the user only about the two
things that are expensive to guess: **the module seams** and **the verification points**.

## Read first

- `docs/brief.md` (product, glossary, `## Architecture` with risk tiers and critical suites).
- `docs/adr/` for decisions in the area.
- `docs/specs/` — if this item already has a spec, amend it in place (same number; git keeps
  the history). Otherwise take the next free `NNNN`.
- The code the feature touches: `contract/`, `apps/api`, `apps/app`, `packages/`.

If the roadmap item is ambiguous, ask which one — that question only.

## Draft silently

Problem, solution, an extensive numbered list of user stories ("As a <actor>, I want …, so
that …"), out of scope, and the **contract delta**: new or changed paths and schemas in
`contract/paths/*.yaml` and `contract/schemas/*.yaml`. For syncable entities, include the
sync fields (`id` UUIDv7, `version`, `deleted_at`) and the conflict rule from the ADRs.

## The interactive checkpoint

Present, then iterate until the user approves:

1. **Modules** — deep modules: a lot of behaviour behind a small, stable interface. For each:
   responsibility, interface sketch (shape, not code), where it lives (`apps/api/internal/…`,
   `apps/app/src/features/…`, `packages/…`), tested yes/no.
2. **Verification points** — the pass/fail checks that prove the feature works, each tied to
   user stories. Prefer checks an agent can run: contract tests, API integration tests
   against Postgres, unit tests, Maestro flows for critical mobile journeys, a screenshot for
   visual changes. Mark which ones become permanent critical suites (they go into
   `test-affected` for the paths involved).

## Write `docs/specs/NNNN-slug/spec.md`

```markdown
# NNNN — <Feature>

Status: draft | approved
Risk: low | normal | high   (from the brief's risk tiers for the paths involved)

## Problem
## Solution
## User stories
1. …
## Contract delta
## Modules
### <Module>
- Responsibility:
- Interface:
- Lives in:
- Tested: yes — <why> | no — <why>
## Verification points
| ID | Check | Command / location | Stories | Permanent |
|----|-------|--------------------|---------|-----------|
| V1 | … | `just test-api -run TestX` | 1, 2 | yes |
## Decisions
(non-module decisions; no file paths or code except a decision-encoding schema or state machine)
## Out of scope
```

Set `Status: approved` only when the user approved the checkpoint. Record new domain terms
in the brief's glossary. Next step: `plan NNNN`.
