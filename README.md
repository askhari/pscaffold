# pscaffold

A professional starting point for products that ship as **iOS / iPadOS / Android / web apps
backed by an API**, built mostly by Claude Code agents.

It contains:

| Path | What it is |
|---|---|
| `template/`, `copier.yml` | [copier](https://copier.readthedocs.io) template for a product monorepo: Expo app, Go or Rust API, OpenAPI contract, Terraform, GitHub Actions, Claude Code harness. |
| `CONTRACT.md` | What the `pscaffold` plugin relies on in every generated product, and how it is versioned. |
| `docs/adr/` | Why the template looks the way it does. |

The skills that drive a product from idea to pull requests live in the **`pscaffold` plugin**
of the [askharilabs marketplace](https://github.com/askhari/claude-plugins):

```
kickoff ──► architect ──► new-project ──► ┌─ spec ──► plan ──► orchestrate ─┐
(product)   (decisions)   (copier repo)   └──────── once per feature ───────┘
```

## How this repo relates to the plugin

```
askhari/pscaffold (this repo)              askhari/claude-plugins
template/ + copier.yml  ◄── renders ───────  plugins/pscaffold   (skills: kickoff … orchestrate)
CONTRACT.md  ◄──────────── relies on ──────  speaks contract N
        │
        ▼ copier copy / copier update
product repo: .copier-answers.yml (template release), .claude/pscaffold.json (contract),
              .claude/settings.json (enables pscaffold@askharilabs)
```

- This repo is the **template**: everything a product is generated from. It has no skills.
- The **plugin** lives in the [askharilabs marketplace](https://github.com/askhari/claude-plugins)
  next to `navigate`, which is unrelated to this template.
- [`CONTRACT.md`](CONTRACT.md) lists what the plugin relies on and carries a version number.
  [`CHANGELOG.md`](CHANGELOG.md) states, for each template release, its contract version and
  the plugin releases that speak it.
- Neither repo knows which products exist: products pull template updates and install the
  plugin themselves.

## Create a product

With the plugin (recommended): install it, then run `kickoff` in an empty directory.

```bash
claude plugin marketplace add askhari/claude-plugins
claude plugin install pscaffold@askharilabs
```

Without the plugin:

```bash
uvx copier copy --trust gh:askhari/pscaffold my-product
```

`--trust` is required because the template runs post-generation tasks (installing
dependencies and generating code from the contract). Generated products enable the plugin in
their `.claude/settings.json`.

## Update a product

Every product carries a `template-update` workflow that checks for a new template release
each week and opens a pull request with the changes. By hand:

```bash
cd my-product
devbox run -- copier update --trust
```

copier applies the template changes between the release the product was generated from
(recorded in the product's `.copier-answers.yml`) and the newest one, keeping local edits;
conflicts show up like git merge conflicts. The template keeps no record of the products
generated from it: each product pulls updates itself.

## Releases

Add the release to `CHANGELOG.md`, then tag it (`git tag v0.2.0 && git push origin v0.2.0`);
copier uses the newest tag for new products and updates. A release that breaks a clause of `CONTRACT.md` bumps the
contract version and needs a matching release of the plugin.

## User-level setup (once per machine)

Some settings cannot live in a repo by design:

- **Auto mode** is configured only in `~/.claude/settings.json` (project settings are ignored
  so a repo cannot grant itself permissions). Run `/auto-mode-setup` or add an `autoMode.environment`
  entry describing your GitHub org and cloud account as trusted.
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
