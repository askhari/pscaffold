#!/usr/bin/env bash
# Stop: before Claude ends its turn, the whole repo must pass `just verify`.
# Skipped when the branch has no changes against main, or when nothing changed since the last
# green run, so conversational turns stay fast.
source "$(dirname "$0")/lib.sh"

base=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || git rev-parse HEAD 2>/dev/null)
fingerprint=$( { git diff "$base" 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | git hash-object --stdin)
empty=$(git hash-object --stdin </dev/null)

[[ "$fingerprint" != "$empty" ]] || exit 0

state_file=.data/verify-ok
[[ "$(cat "$state_file" 2>/dev/null)" != "$fingerprint" ]] || exit 0

check_or_block "just verify" verify
mkdir -p .data
echo "$fingerprint" >"$state_file"
