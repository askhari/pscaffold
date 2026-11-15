# Template contract

**Contract version: 1** (declared to products in `template/.claude/pscaffold.json`).

The `pscaffold` plugin ([askhari/claude-plugins](https://github.com/askhari/claude-plugins),
`plugins/pscaffold`) contains no code: its skills tell Claude to run recipes, read files and
follow conventions that this template provides. This file lists everything the plugin relies
on. A generated product promises all of it.

## Clauses

1. **copier answers.** `architect` writes `docs/copier-answers.yml` and `new-project` passes it
   to `copier copy --data-file`. The question names and choices in `copier.yml` are part of
   the contract: `project_name`, `project_slug`, `github_owner`, `bundle_id`, `backend`
   (`go` | `rust`), `infra_target` (`digitalocean` | `vps`), `do_region`. copier never overwrites
   `docs/brief.md`, `docs/adr/README.md` or `.github/CODEOWNERS` (`_skip_if_exists`).
2. **Document layout.** `docs/brief.md`, `docs/adr/NNNN-slug.md`,
   `docs/specs/NNNN-slug/spec.md`, `docs/specs/NNNN-slug/tasks.md`. The task table has the
   columns ID, Task, Type (AFK | HITL), Blocked by, Risk (low | normal | high), Model
   (haiku | sonnet | opus | —); `plan` writes it and `orchestrate` reads it.
3. **`just` recipes.** `setup`, `verify`, `generate`, `check-file`, `test-api`,
   `test-affected`, `db-up`, `db-prune`. Names and meaning are stable; their implementation is
   not part of the contract.
4. **GitHub conventions.** Task branches `task/NNNN-MM-<slug>`; PR titles `[NNNN-MM] <title>`;
   exactly one `risk:low|normal|high` label per PR (created by `scripts/github-bootstrap.sh`,
   enforced by the `pr-policy` workflow); the secret names listed by `new-project`.
5. **The `implementer` agent** (`.claude/agents/implementer.md`): dispatched by name by
   `orchestrate`, runs in its own worktree, cannot finish until `just verify` passes, and ends
   with the fixed report (Task / PR / Verification / just verify / Done when / Notes).
6. **Stack.** The template implements what the plugin's `PREFERENCES.md` assumes: Expo
   universal app, OpenAPI contract as the source of truth, Go or Rust API, offline-first sync
   conventions, auth inside the API, Terraform for DigitalOcean.

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
