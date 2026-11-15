#!/usr/bin/env bash
# Setup script for Claude Code cloud environments and fresh CI machines:
# installs Devbox tools and project dependencies. Languages come from the environment image.
set -euo pipefail

if ! command -v devbox >/dev/null 2>&1; then
  curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
fi
devbox install
devbox run -- just setup
