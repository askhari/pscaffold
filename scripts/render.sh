#!/usr/bin/env bash
# Render the template into DEST with the given backend. Extra arguments go to copier.
# COPIER overrides the copier command (CI uses an ephemeral `uvx copier@<version>`).
set -euo pipefail
backend=$1 dest=$2
shift 2
root=$(cd "$(dirname "$0")/.." && pwd)
rm -rf "$dest"
# shellcheck disable=SC2086 # COPIER may hold a command plus its arguments.
${COPIER:-copier} copy --trust --defaults --vcs-ref=HEAD \
  -d project_name="Sample Product" -d backend="$backend" "$@" \
  "$root" "$dest"
