#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): format and lint the edited file.
# Exit 2 shows the lint errors to Claude right after the edit.
source "$(dirname "$0")/lib.sh"

file=$(field "$HOOK_INPUT" tool_input.file_path)
[[ -n "$file" ]] || exit 0
# Lint inside the checkout that owns the file (the main repo or a task worktree).
enter_checkout "$(dirname "$file")" || exit 0

check_or_block "Lint of ${file#"$PWD"/}" check-file "$file"
