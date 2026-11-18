# Changelog

All notable changes to the pscaffold template. Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions are git tags (`vX.Y.Z`)
that copier uses for new products and updates. Each release names the template contract
version it implements (see `CONTRACT.md`) and the `pscaffold` plugin releases that speak it.

## [Unreleased]

## [0.2.0] - 2026-11-18

Template contract **2** · works with the pscaffold plugin **0.3.x**.

### Changed
- **Breaking:** products deploy onto a shared platform instead of their own stack.
  `infra/deploy/compose.yaml` runs only the API container (`<platform_product>-<env>-api`,
  `env_file: db.env`, external network `platform`, a memory limit, no published ports) and
  `deploy-dev` writes it into `/opt/platform/products/<platform_product>-dev/`. See ADR 8.
- Each product gets its own local Postgres port: the default of `dev_db_port` is derived
  from the slug (20000–29999) instead of the fixed 54320, still overridable with
  `DEV_DB_PORT`. Existing products keep the port recorded in their `.copier-answers.yml`.
- Local and CI PostgreSQL is 18.7 (`postgresql_18`), the major the platform runs;
  `infra/README.md` in the product is the one place that states which major to match.
- `scripts/render.sh` renders each backend under its own slug and stops a Postgres left
  running by a previous render before deleting it.

### Added
- copier question `platform_product`: the product's name on the platform, by default the
  slug without dashes (`re-memory` → `rememory`).
- Recipe `just format` (Prettier over the whole repo). A post-generation task runs it once on
  `copier copy`, so the brief, ADRs and `docs/copier-answers.yml` written before the render
  no longer fail `just verify`.

### Removed
- **Breaking:** copier questions `infra_target` and `do_region`, `infra/terraform/`, the
  `terraform` workflow, the recipe `check-infra`, Terraform and tflint from Devbox, and the
  standalone stack's PostgreSQL and Caddy services (`infra/deploy/Caddyfile`,
  `infra/deploy/env.example`). Machines are created in the platform's repository.

### Updating a product from 0.1.x
- `copier update` asks for `platform_product` and deletes `infra/terraform/` and the
  standalone deploy files. Remove the old `/opt/<slug>` stack from the host by hand, and drop
  the `DIGITALOCEAN_TOKEN` / `SPACES_*` secrets and the `DEPLOY_SSH_PUBLIC_KEY` variable.

## [0.1.1] - 2026-11-16

Template contract **1** · works with the pscaffold plugin **0.2.x**.

### Added
- Agent commit identity: copier questions `agent_name` / `agent_email`, the recipe
  `just agent-identity <model> <task>` and a `commit-msg` hook that add `Agent-Model:` and
  `Agent-Task:` trailers in task worktrees. The `implementer` agent runs it before its first
  commit. Contract clause 6.
- `scripts/github-bootstrap.sh` allows merge commits only (no squash or rebase), so
  `git blame` keeps agent and human authorship apart.
- Deny rules for `git commit --no-verify` and `git config --global`.

## [0.1.0] - 2026-11-15

Template contract **1** · works with the `pscaffold` plugin **0.2.x** from
[askhari/claude-plugins](https://github.com/askhari/claude-plugins).

### Added
- copier template for a product monorepo: Expo universal app, OpenAPI contract with generated
  TS client and server interface, Go or Rust API, PostgreSQL, Terraform for DigitalOcean or an
  own VPS, GitHub Actions (ci, pr-policy, mobile, deploy-dev, terraform, Claude review).
- Claude Code harness: edit, task-completed and stop hooks that lint and run `just verify`;
  the `implementer` agent that builds one task in its own worktree and opens one PR.
- Worktree-safe local development: shared Postgres cluster, per-worktree databases,
  `just db-prune` for databases of removed worktrees.
- `CONTRACT.md` and `.claude/pscaffold.json`: what the plugin relies on, versioned.
- `.claude/settings.json` turns off Claude's commit and PR attribution, so commits carry only
  the developer's identity.
- `template-update` workflow: each product opens a pull request when a new template release
  is out.

### Changed
- The `pscaffold` plugin moved to the public askharilabs marketplace; this repo only holds the
  template.
- `github_owner` has no default; every product states its owner.

[Unreleased]: https://github.com/askhari/pscaffold/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/askhari/pscaffold/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/askhari/pscaffold/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/askhari/pscaffold/releases/tag/v0.1.0
