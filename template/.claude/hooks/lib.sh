#!/usr/bin/env bash
# Shared helpers for the Claude Code hooks. Hooks run outside the Devbox shell, so commands
# are wrapped with `devbox run` unless the Devbox environment is already active.

set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

# Read a field from the hook's JSON input (stdin) using Node, which every developer has.
# Usage: hook_input=$(cat); field "$hook_input" tool_input.file_path
field() {
  node -e '
    let v = JSON.parse(process.argv[1] || "{}");
    for (const k of process.argv[2].split(".")) v = v == null ? undefined : v[k];
    if (v !== undefined && v !== null) process.stdout.write(String(v));
  ' "$1" "$2" 2>/dev/null
}

# Run a just recipe inside the Devbox environment.
run_just() {
  if [[ -n "${DEVBOX_SHELL_ENABLED:-}" ]] && command -v just >/dev/null 2>&1; then
    just "$@"
  else
    devbox run --quiet -- just "$@"
  fi
}

# Run a just recipe; on failure print the tail of its output to stderr and exit 2, which makes
# Claude Code feed the failure back to the model so it fixes it before moving on.
check_or_block() {
  local label=$1; shift
  local out
  if out=$(run_just "$@" 2>&1); then
    return 0
  fi
  {
    echo "$label failed. Fix it before continuing. Last lines of output:"
    echo "$out" | tail -n 80
  } >&2
  exit 2
}
