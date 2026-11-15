# Verification lives in the harness, not in pipeline bookkeeping

This plugin replaces the earlier `navigate` pipeline. We keep its interviews, per-feature specs
and vertical slices, but drop its custom orchestrator binary and the task reconcile machinery
(spec-hash, delta tasks, status directories). With current models the reliable controls are
mechanical: deny rules for irreversible actions, hooks that run `just check-file`,
`just test-affected` and `just verify` and exit 2 on failure, CI on every pull request, and
review effort scaled by risk. Each task becomes a Claude Code session that ends in a PR, so the
PR state is the task state.
