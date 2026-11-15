#!/usr/bin/env bash
# Stop (main session) and SubagentStop (implementer agent): before Claude ends its turn, the
# checkout it worked in must pass `just verify`.
# Skipped when the branch has no changes against main, or when nothing changed since the last
# green run, so conversational turns stay fast. After three blocked attempts in a row it lets
# Claude stop, so a session that must stop to ask for a decision is not trapped; the failure
# still shows in the PR's CI.
source "$(dirname "$0")/lib.sh"

base=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || git rev-parse HEAD 2>/dev/null)
fingerprint=$( { git diff "$base" 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | git hash-object --stdin)
empty=$(git hash-object --stdin </dev/null)

[[ "$fingerprint" != "$empty" ]] || exit 0

state_file=.data/verify-ok
blocks_file=.data/verify-blocks
max_blocks=3
mkdir -p .data
[[ "$(cat "$state_file" 2>/dev/null)" != "$fingerprint" ]] || exit 0

if out=$(run_just verify 2>&1); then
  echo "$fingerprint" >"$state_file"
  rm -f "$blocks_file"
  exit 0
fi

blocks=$(( $(cat "$blocks_file" 2>/dev/null || echo 0) + 1 ))
if (( blocks >= max_blocks )); then
  rm -f "$blocks_file"
  exit 0
fi
echo "$blocks" >"$blocks_file"
{
  echo "just verify failed (attempt $blocks of $max_blocks before stopping is allowed). Fix it, or if you"
  echo "must stop to ask for a decision, say plainly that verify is failing. Last lines of output:"
  echo "$out" | tail -n 80
} >&2
exit 2
