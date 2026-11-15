---
name: architect
description: Architecture interview for a product with a decided brief — settle the decisions the code cannot show (cross-cutting concerns, sync rules, infra target, risk profile) as ADRs and produce the copier answers for `new-project`. Second step of the pscaffold pipeline. Use after `kickoff`, on "architect", "decide the architecture", or to audit an existing product's architecture against its brief.
argument-hint: "[product directory] [new|change|audit]"
---

# architect

The stack is already decided by `PREFERENCES.md` (Expo universal app, Go or Rust API,
PostgreSQL, OpenAPI contract, Terraform, GitHub Actions, EAS). Do not re-open it. Your job is
the decisions that are product-specific and expensive to reverse, written down where agents
will find them.

## Modes

- `new` (default when there is no `.copier-answers.yml`): run every phase.
- `change`: a change is in hand. Read the repo first (CLAUDE.md, docs/adr, contract,
  infra), then run only the phases the change touches.
- `audit`: read the repo and walk every phase asking "is this still right for the brief at
  today's scale?". Recommend deltas.

## Before asking anything

Read `docs/brief.md`, `PREFERENCES.md` (`../../PREFERENCES.md` relative to this skill's directory), and
`docs/adr/`. If the brief is missing or undecided, send the user back to `kickoff`.

## Interview

One question at a time, each with your concrete recommendation. Skip what the preferences or
existing ADRs settle unless the brief gives a reason to deviate.

**A. Deviations from the preferences.** Does anything in the brief break a default (e.g. no
mobile, heavy realtime, regulated data, SEO-critical public pages that need a separate site)?
If not, say so and move on.

**B. Cross-cutting concerns** — the part agents get wrong when it is left implicit:
1. *Identity*: which sign-in methods for the MVP; single user vs organizations/tenants;
   roles. Remind the user that offering Google/Microsoft on iOS requires Sign in with Apple.
2. *Offline and sync*: which entities sync to the device; for each, the conflict rule
   (last-write-wins is the default; name the entities where it is wrong); what must never be
   editable offline (payments, unique handles, …).
3. *Data ownership and privacy*: personal data stored, retention, deletion on account removal,
   export obligations.
4. *Files and media*: whether users upload files (→ object storage), sizes.
5. *Notifications and background work*: push, email, scheduled jobs (→ a worker process?).
6. *Anything else the brief implies*: payments, i18n, search, realtime.

**C. Infrastructure target.** DigitalOcean or an own VPS. Compare on the user's weights —
monthly cost first, operational effort (setup amortized) second, lock-in third — with
rough numbers for the MVP size. Managed Postgres versus Postgres in the compose stack for dev.
Only `dev` exists at first; record when `prod` should be added (first external user, first
TestFlight build).

**D. Risk profile and verification.** Decide, per area, how much human review a change needs
and what must always be tested:
- *High risk* (two reviews or explicit human approval): typically `apps/api/**/auth/**`,
  migrations, `infra/**`, anything touching payments or personal data.
- *Normal* (one review): product code.
- *Low* (green checks are enough): docs, copy, tests-only changes.
- *Critical test suites*: which suites `just test-affected` must always run when a path
  changes (e.g. auth tests whenever `auth/` changes).

## Outputs

Write only real decisions.

- `docs/adr/NNNN-slug.md` — one per decision that is hard to reverse, surprising without
  context, and the result of a real trade-off. Sequential numbers, 1–3 sentences each; add
  "Considered options" only when the rejected options are worth remembering. Typical
  outputs: sync conflict rules, tenancy model, infra target.
- `docs/brief.md` — append an `## Architecture` section with one-liners: deviations,
  cross-cutting decisions, infra target, risk tiers, critical suites. Link the ADRs.
- `docs/copier-answers.yml` — the answers `new-project` will feed to copier:

  ```yaml
  project_name: "<Product name>"
  project_slug: "<kebab-case>"
  backend: go            # go | rust
  infra_target: digitalocean   # digitalocean | vps
  github_owner: "<org or user>"
  bundle_id: "com.<owner>.<slug>"
  ```

In `change`/`audit` mode on an existing repo, also list the concrete follow-ups (template
update, CODEOWNERS change, new critical suite) and offer to hand them to `spec`/`plan`.

Finish by naming the next step: `new-project` (new) or `spec` (change).
