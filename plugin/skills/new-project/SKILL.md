---
name: new-project
description: Generate a product monorepo from the pscaffold copier template using the answers decided by `architect`, wire in the product's risk profile, and prove it is green with `just verify`. Third step of the pscaffold pipeline. Use after `architect`, or on "new project", "generate the repo", "scaffold the product".
argument-hint: "[product directory]"
disable-model-invocation: true
---

# new-project

Turn the decided brief into a working repository. Done means: the repo is generated, its
`just verify` passes locally, and the user has a checklist for the steps only they can do.

## Inputs

- `docs/brief.md` and `docs/adr/` in the product directory.
- `docs/copier-answers.yml` from `architect`. If it is missing, stop and send the user to
  `architect`.

## Steps

1. **Check the machine.** `devbox version`, `go version` or `cargo --version` (per backend),
   `node --version` and `corepack --version`. If a language is missing, tell the user which
   manager to use (Go toolchain, rustup, fnm) — never install languages yourself.

2. **Render.** From the product directory:

   ```bash
   # copier is not installed yet in a fresh directory; run it ephemerally:
   devbox run --config <pscaffold checkout> -- \
     copier copy --trust --data-file docs/copier-answers.yml <template source> .
   # or, without a pscaffold checkout:
   uvx copier copy --trust --data-file docs/copier-answers.yml <template source> .
   ```

   `<template source>` is `gh:askhari/pscaffold` (optionally `--vcs-ref vX.Y.Z`) or the
   path of a local pscaffold checkout when the user is developing the template.
   copier keeps `docs/brief.md` and `docs/adr/*` (they are in `_skip_if_exists`). Its
   post-generation tasks install dependencies and generate code from the contract.

3. **Apply the risk profile** from the brief's `## Architecture` section:
   - `.github/CODEOWNERS`: add the owners for the high-risk paths.
   - `justfile`, recipe `test-affected`: add the critical suites the architect named, keyed
     by path.
   - Risk labels (`risk:low|normal|high`) are created by `scripts/github-bootstrap.sh`; edit it
     only if the architect added tiers.

4. **Verify.** `devbox run -- just verify` (copier's task already ran `just setup`; run it
   again if it was skipped). Fix anything red —
   it is the template's contract that a fresh project is green. If the fix belongs in the
   template, tell the user and describe the fix for pscaffold.

5. **Commit** on `main`: `chore: generate from pscaffold <version>`.

6. **Remote — ask first.** Creating the GitHub repository and pushing is outward-facing: show
   the exact `gh repo create <owner>/<slug> --private --source . --push` command and run it
   only after the user agrees.

## Hand the user this checklist

These need a human (accounts, secrets, consoles). Write it to the final message, not a file:

- GitHub: review and run `scripts/github-bootstrap.sh` (risk labels, `dev` environment,
  auto-merge, branch protection requiring `ci` and `risk-label`).
- Secrets in the `dev` environment: `DEPLOY_HOST`, `DEPLOY_SSH_KEY` and `EXPO_TOKEN` (always);
  `DIGITALOCEAN_TOKEN`, `SPACES_ACCESS_KEY_ID`, `SPACES_SECRET_ACCESS_KEY` (digitalocean target).
- Claude review on PRs: run `/install-github-app` in Claude Code (adds `ANTHROPIC_API_KEY` or
  `CLAUDE_CODE_OAUTH_TOKEN`).
- Terraform state bucket (digitalocean): create the Spaces bucket named in
  `infra/terraform/envs/dev/backend.hcl` once, by hand; set the `DEPLOY_SSH_PUBLIC_KEY`
  variable in the `dev` environment.
- Dev host: follow `infra/README.md` (copy the compose files and `.env`, `docker login ghcr.io`).
- Expo: `npx eas-cli@latest init` inside `apps/app` to create the EAS project; because the
  config is dynamic, add the printed `extra.eas.projectId` to `app.config.ts` by hand.
- Auto mode (user-level, once per machine): describe the GitHub org and cloud account in
  `~/.claude/settings.json` → `autoMode.environment`, or run `/auto-mode-setup`.

Next step: `spec` on the first roadmap item (usually authentication, then sync).
