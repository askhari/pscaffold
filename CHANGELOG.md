# Changelog

All notable changes to the pscaffold template. Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions are git tags (`vX.Y.Z`)
that copier uses for new products and updates. Each release names the template contract
version it implements (see `CONTRACT.md`) and the `pscaffold` plugin releases that speak it.

## [Unreleased]

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

[Unreleased]: https://github.com/askhari/pscaffold/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/askhari/pscaffold/releases/tag/v0.1.0
