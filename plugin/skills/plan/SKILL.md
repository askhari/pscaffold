---
name: plan
description: Slice ONE approved pscaffold spec into vertical-slice tasks, each with a pass/fail verification command, dependencies and a risk tier, written to docs/specs/NNNN-slug/tasks.md for `orchestrate`. Autonomous — doubts become HITL tasks instead of questions. Use after `spec`, or on "plan NNNN", "slice this spec", "tasks for <spec>".
argument-hint: "<spec number or path>"
---

# plan

Cut one approved spec into tasks an agent can finish alone in one session, ending in one PR.
Do not block on questions: whatever you cannot decide becomes a HITL task that blocks the
tasks depending on it.

## Read first

`docs/specs/NNNN-*/spec.md` (must be `Status: approved`; otherwise send the user back to
`spec`), `docs/brief.md`, the ADRs in the area, the code involved, and the existing
`tasks.md` if this is a re-plan.

## Slicing rules

- **Vertical tracer bullets.** Each task cuts through every layer it needs (contract →
  migration → API → client → screen → tests) and is demoable on its own. Many thin slices
  beat a few thick ones; one session should finish a task in well under a day.
- **Contract first.** A task that changes `contract/` blocks every task that consumes the
  change. Keep contract changes small and in their own task when several slices share them.
- **One writer per hotspot.** Two tasks that can run in parallel must not both edit the same
  contract file, migration or shared module. Serialize them with `blocked-by` instead.
- **Verification is mandatory.** Every AFK task names the exact command that proves it
  (taken from the spec's verification points) and must also leave `just verify` green.
- **Risk** comes from the paths a task touches (brief's risk tiers); it decides how much
  human review the PR needs.
- **Model** is the cheapest worker that can do the task well; `orchestrate` dispatches the
  `implementer` agent with it. Pick by what the task demands, not by its size:
  - `haiku` — mechanical change with an obvious shape: copy, docs, config, renames, adding a
    field that follows an existing pattern. Only for `low` risk.
  - `sonnet` — the default: a normal vertical slice that follows patterns already in the
    codebase.
  - `opus` — new patterns or subtle logic: the first slice of a new module, auth, sync and
    conflict resolution, concurrency, data migrations, anything `high` risk.

  When unsure between two, pick the cheaper one; `orchestrate` escalates a task that fails
  judgment. HITL tasks have no model (`—`).
- **Inherently HITL** (never AFK): creating accounts or apps in Apple / Google / Microsoft /
  Expo consoles, OAuth client registration, signing certificates, store listings, secrets,
  production data, DNS for real domains, visual sign-off of a new screen, any irreversible
  migration on shared data.

## Write `docs/specs/NNNN-slug/tasks.md`

```markdown
# NNNN — <Feature> · tasks

| ID | Task | Type | Blocked by | Risk | Model |
|----|------|------|------------|------|-------|
| NNNN-01 | … | AFK | — | normal | sonnet |
| NNNN-02 | … | HITL | — | high | — |

## NNNN-01 — <title>
Stories: 1, 2 · Modules: <names>
### Build
End-to-end behaviour of the slice. No file paths or code beyond a decision-encoding schema.
### Done when
- [ ] <acceptance criterion>
- [ ] `<verification command>` passes and its output is pasted in the PR
- [ ] `just verify` passes
```

HITL task bodies use `### Decision needed`, `### Options`, `### Done when` (decision recorded
where, dependants unblocked).

Task status is **not** stored here: a task is in progress when a PR whose title starts with
`[NNNN-MM]` is open, and done when that PR is merged. On a re-plan, keep the IDs of tasks
that still exist, never reuse a number, and for a changed task whose PR already merged add a
new task that amends it instead of rewriting history.

Report the dependency graph, the HITL tasks and how many tasks go to each model. Next step:
`orchestrate NNNN`, run from a session on the strongest model you have.
