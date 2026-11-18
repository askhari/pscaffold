#!/usr/bin/env bash
# Render the template into DEST with the given backend. Extra arguments go to copier.
# Each backend gets its own slug, hence its own local Postgres port, so both renders can run
# side by side.
# COPIER overrides the copier command (CI uses an ephemeral `uvx copier@<version>`).
set -euo pipefail
backend=$1 dest=$2
shift 2
root=$(cd "$(dirname "$0")/.." && pwd)
# A previous render may have left its local Postgres running: stop it before deleting its data.
pidfile="$dest/.data/postgres/postmaster.pid"
if [[ -f "$pidfile" ]] && pid=$(head -n 1 "$pidfile") && kill -INT "$pid" 2>/dev/null; then
  while kill -0 "$pid" 2>/dev/null; do sleep 0.2; done
fi
rm -rf "$dest"
# shellcheck disable=SC2086 # COPIER may hold a command plus its arguments.
${COPIER:-copier} copy --trust --defaults --vcs-ref=HEAD \
  -d project_name="Sample Product" -d project_slug="sample-$backend" -d github_owner=example \
  -d backend="$backend" "$@" \
  "$root" "$dest"
