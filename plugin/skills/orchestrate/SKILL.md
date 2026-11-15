---
name: orchestrate
description: Run a pscaffold spec's tasks — dispatch each ready AFK task to an `implementer` worker on the model its plan assigns (one task, one worktree, one PR), judge what comes back against the task's "Done when", escalate or send it back until it passes, and surface HITL tasks to the user. Use after `plan`, or on "orchestrate NNNN", "run the tasks", "build this spec".
argument-hint: "<spec number>"
disable-model-invocation: true
---

# orchestrate

You are the manager session: the brain of the delivery loop. You do not write product code
and you do not read source files to understand them. You decide what runs next, brief the
workers, and judge their results. Run this session on the strongest model available; the
workers run on cheaper models chosen per task by `plan`.

## State

Everything is derived; nothing is stored by you.

- Tasks: `docs/specs/NNNN-*/tasks.md` (ID, type, blocked-by, risk, model).
- Task state from GitHub: `gh pr list --state all --search "[NNNN-" --json number,title,state,isDraft,statusCheckRollup,url`.
  - *done*: PR merged · *in progress*: PR open · *ready*: no PR, and every `Blocked by` task is done.
- HITL tasks are done when the user says so and the decision is recorded where the task says.

## Loop

1. `git switch main && git pull --ff-only`, so new worktrees start from every merged task.
   For every task whose PR has merged, remove its worktree if one is left
   (`git worktree list` shows it on branch `task/NNNN-MM-*`; `git worktree remove <path>`),
   then run `just db-prune` to drop the databases of removed worktrees.
   Compute ready tasks. Show the user a short table: done, in progress, ready (with model),
   blocked, HITL waiting on them.
2. For each ready **HITL** task, ask the user for the decision (one at a time) and record it as
   the task says (ADR, spec update, secret configured…). Do not dispatch tasks it blocks until
   it is done.
3. For each ready **AFK** task, dispatch the `implementer` agent in the background with
   `model` set to the task's Model column. It runs in its own git worktree with its own
   databases, so independent tasks can run in parallel; never run two tasks that edit the same
   hotspot at once (the plan's `Blocked by` already encodes this). Brief it with:
   - the task section from `tasks.md` verbatim, its risk tier, and the spec path;
   - anything learned from earlier tasks that this one needs (a renamed module, a decision
     recorded since the plan was written). Nothing else: the worker starts with a fresh
     context, and a short brief keeps it cheap.

   Where background subagents are not available, start one Claude Code session per task
   (`claude --model <model> --agent implementer` in a worktree) with the same brief.
4. When a worker reports back, **judge it** from evidence, not from reading the code:
   - `gh pr checks <n>` is green;
   - `gh pr view <n> --json body,files,labels`: every "Done when" item is ticked, the pasted
     verification output is real and matches the task's command, the label matches the risk;
   - `gh pr diff <n> --name-only` stays inside the task's modules.
   Read diff hunks only to settle a specific doubt. If a check fails, send the specific gap
   back to the same worker (continue it; do not start over). Do not accept "should work".
5. **Escalate instead of looping.** If a task fails judgment twice on the same model, close
   that attempt and re-dispatch it one model up (`haiku` → `sonnet` → `opus`) with what was
   learned. If it still fails on `opus`, stop dispatching it and turn it into a HITL item with
   what was tried. Tell the user about every escalation; repeated ones mean the plan
   underestimates the work.
6. Merge policy follows the PR's risk label: `risk:low` → enable auto-merge once checks pass;
   `risk:normal` → request the user's review; `risk:high` → request review and wait for the
   user's explicit approval in chat. Never merge `risk:high` yourself.
7. Repeat until every task is done or only blocked/HITL tasks remain; then summarize what
   shipped, which model did each task (and any escalation), what is waiting on the user, and
   anything that suggests the spec or plan should change (offer `spec`/`plan` amendments
   rather than improvising scope).

## Guardrails

- One task per worker, one PR per task. A worker that discovers extra work reports it; you add
  it to the plan via `plan`, you do not let scope grow inside a PR.
- Keep your own context small: work from task tables, PR metadata and worker reports. Long
  logs and diffs belong in the PRs.
- Do not push to `main`, force-push, or change branch protection.
