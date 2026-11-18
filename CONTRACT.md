# Template contract

**Contract version: 2** (declared to products in `template/.claude/pscaffold.json`).

The `pscaffold` plugin ([askhari/claude-plugins](https://github.com/askhari/claude-plugins),
`plugins/pscaffold`) contains no code: its skills tell Claude to run recipes, read files and
follow conventions that this template provides. This file lists everything the plugin relies
on. A generated product promises all of it.

## Clauses

1. **copier answers.** `architect` writes `docs/copier-answers.yml` and `new-project` passes it
   to `copier copy --data-file`. The question names and choices in `copier.yml` are part of
   the contract: `project_name`, `project_slug`, `github_owner`, `bundle_id`, `agent_name`,
   `agent_email`, `backend` (`go` | `rust`), `platform_product` (defaults to the slug without
   dashes), `dev_db_port` (defaults to a port derived from the slug). copier never overwrites `docs/brief.md`, `docs/adr/README.md` or
   `.github/CODEOWNERS` (`_skip_if_exists`).
2. **Document layout.** `docs/brief.md`, `docs/adr/NNNN-slug.md`,
   `docs/specs/NNNN-slug/spec.md`, `docs/specs/NNNN-slug/tasks.md`. The task table has the
   columns ID, Task, Type (AFK | HITL), Blocked by, Risk (low | normal | high), Model
   (haiku | sonnet | opus | —); `plan` writes it and `orchestrate` reads it.
3. **`just` recipes.** `setup`, `verify`, `generate`, `check-file`, `test-api`,
   `test-affected`, `format`, `db-up`, `db-prune`, `agent-identity <model> <task>`. Names and meaning are
   stable; their implementation is not part of the contract.
4. **GitHub conventions.** Task branches `task/NNNN-MM-<slug>`; PR titles `[NNNN-MM] <title>`;
   exactly one `risk:low|normal|high` label per PR (created by `scripts/github-bootstrap.sh`,
   enforced by the `pr-policy` workflow); the secret names listed by `new-project`
   (`DEPLOY_HOST`, `DEPLOY_SSH_KEY`, `EXPO_TOKEN` in the `dev` environment).
5. **The `implementer` agent** (`.claude/agents/implementer.md`): dispatched by name by
   `orchestrate`, runs in its own worktree, cannot finish until `just verify` passes, and ends
   with the fixed report (Task / PR / Verification / just verify / Done when / Notes).
6. **Agent commits.** In a task worktree, `just agent-identity <model> NNNN-MM` makes every
   commit authored by `agent_name <agent_email>` and adds the trailers `Agent-Model: <model>`
   and `Agent-Task: NNNN-MM`. The main checkout keeps the developer's identity. PRs merge with
   merge commits only (`scripts/github-bootstrap.sh` disables squash and rebase).
7. **Stack.** The template implements what the plugin's `PREFERENCES.md` assumes: Expo
   universal app, OpenAPI contract as the source of truth, Go or Rust API, offline-first sync
   conventions, auth inside the API, PostgreSQL 18.
8. **Deployment.** The product creates no infrastructure. `deploy-dev` deploys the API
   container `<platform_product>-<env>-api` into `/opt/platform/products/<platform_product>-<env>/`
   on a shared platform that provides PostgreSQL (`DATABASE_URL` in `db.env`), TLS and the
   external Docker network `platform`. `infra/README.md` in the product states the details.

## History

- **2**: `infra_target` and `do_region` removed together with the per-product Terraform and
  the standalone Compose stack (own PostgreSQL and Caddy); `platform_product` and clause 8
  added.
- **1**: first version.

## Changing it

- **Compatible** (no version bump): adding a recipe, an optional task-table column, a copier
  question with a default, a new choice. Release the template whenever.
- **Breaking**: renaming or removing anything above, changing the task-table or PR-title
  format, removing a copier choice, changing the implementer's report. Then:
  1. bump the contract version here and in `template/.claude/pscaffold.json`;
  2. release the template as a new minor before 1.0 (`v0.N.0`), a new major after;
  3. release the plugin with the skills updated for the new version and its
     compatibility table updated.

The plugin's `new-project` and `orchestrate` stop when a product's contract version is not
the one they speak, so a mismatch fails loudly instead of half-working.
