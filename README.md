# pscaffold

A professional starting point for products that ship as **iOS / iPadOS / Android / web apps
backed by an API**, built mostly by Claude Code agents.

It contains:

| Path | What it is |
|---|---|
| `template/`, `copier.yml` | [copier](https://copier.readthedocs.io) template for a product monorepo: Expo app, Go or Rust API, OpenAPI contract, Terraform, GitHub Actions, Claude Code harness. |
| `plugin/` | Claude Code plugin with the product pipeline skills. |
| `plugin/PREFERENCES.md` | Standing decisions every product inherits. |
| `docs/adr/` | Why the template looks the way it does. |

## The pipeline

```
kickoff ──► architect ──► new-project ──► ┌─ spec ──► plan ──► orchestrate ─┐
(product)   (decisions)   (copier repo)   └──────── once per feature ───────┘
```

| Skill | Altitude | Output |
|---|---|---|
| `kickoff` | Product: problem, users, MVP, roadmap | `docs/brief.md` |
| `architect` | Decisions the code cannot show: shape, cross-cutting concerns, infra, risk | `docs/adr/*`, brief updates, copier answers |
| `new-project` | Generates the repo from the template and verifies it is green | A product repo whose `just verify` passes |
| `spec` | One roadmap item → modules, user stories, verification points | `docs/specs/NNNN-slug/spec.md` |
| `plan` | One spec → vertical-slice tasks, each with a pass/fail check, risk tier and worker model | `docs/specs/NNNN-slug/tasks.md` |
| `orchestrate` | Manager on the strongest model; dispatches each task to the `implementer` agent on its model, in its own worktree | One PR per task |

The human is in the loop for the interviews, for HITL tasks, and for reviewing risky PRs.
Everything else is verified mechanically (hooks + CI).

## Install the plugin

```bash
claude plugin marketplace add askhari/pscaffold
claude plugin install pscaffold@pscaffold
```

For local development of the plugin itself: `claude plugin marketplace add ./` from this repo.

## Create a product without the plugin

```bash
devbox run -- copier copy --trust gh:askhari/pscaffold my-product
```

`--trust` is required because the template runs post-generation tasks (installing
dependencies and generating code from the contract).

## Update an existing product

```bash
cd my-product
devbox run -- copier update --trust
```

copier applies the template changes between the version the product was generated from
(recorded in `.copier-answers.yml`) and the latest tag, keeping local edits. Conflicts show
up like git merge conflicts. Tag template releases (`git tag v0.2.0`) so products update
between known versions.

## User-level setup (once per machine)

Some settings cannot live in a repo by design:

- **Auto mode** is configured only in `~/.claude/settings.json` (project settings are ignored
  so a repo cannot grant itself permissions). Run `/auto-mode-setup` or add an `autoMode.environment`
  entry describing your GitHub org and DigitalOcean account as trusted.
- **Languages**: Go, Rust (`rustup`), Node (`fnm` with `--use-on-cd`). The template pins
  versions; your managers pick them up.
- **Devbox** for support tools; `direnv` is optional (`devbox generate direnv`).
- **Mobile**: Xcode and Android Studio are system installs.

## Working on the template

```bash
devbox shell
just test go      # render with the Go backend and run its `just verify`
just test rust    # same for Rust
```
