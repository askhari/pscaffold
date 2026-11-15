#!/usr/bin/env bash
# Shared helpers for the Claude Code hooks. Hooks run outside the Devbox shell, so commands
# are wrapped with `devbox run` unless the Devbox environment is already active.

set -uo pipefail

# Read a field from a JSON document using Node, which every developer has.
# Usage: field "$HOOK_INPUT" tool_input.file_path
field() {
  node -e '
    let v = JSON.parse(process.argv[1] || "{}");
    for (const k of process.argv[2].split(".")) v = v == null ? undefined : v[k];
    if (v !== undefined && v !== null) process.stdout.write(String(v));
  ' "$1" "$2" 2>/dev/null
}

# The hook's JSON input (stdin), read once.
HOOK_INPUT=$(cat)

# Work in the checkout the session is using. Agent tasks run in git worktrees, so this is not
# always $CLAUDE_PROJECT_DIR.
enter_checkout() {
  local dir=$1 top
  [[ -n "$dir" ]] || return 1
  top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || return 1
  cd "$top" || return 1
}
enter_checkout "$(field "$HOOK_INPUT" cwd)" \
  || enter_checkout "${CLAUDE_PROJECT_DIR:-$PWD}" \
  || exit 0

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
