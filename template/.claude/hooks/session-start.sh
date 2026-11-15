#!/usr/bin/env bash
# SessionStart: report toolchain mismatches as context before any work starts.
source "$(dirname "$0")/lib.sh"

if ! out=$(run_just doctor --quiet 2>&1); then
  echo "Toolchain check (just doctor) reported problems; fix them or tell the user before relying on test results:"
  echo "$out"
fi
exit 0
