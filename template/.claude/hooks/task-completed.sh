#!/usr/bin/env bash
# TaskCompleted: a task can only be marked complete when the tests affected by the change pass.
source "$(dirname "$0")/lib.sh"

check_or_block "just test-affected" test-affected
