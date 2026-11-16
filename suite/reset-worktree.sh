#!/bin/bash
# Resets the scratch worktree between runs (suite "How to run"). Run from the scratch worktree.
# Goes back to the fixture commit (local tag pilot-fixtures-base), dropping edits, any new
# untracked file (git-ignored ones such as .env stay), and any commit a run made (case E5).
# Refuses to run on any branch but pilot/conformance, so it can never touch a real checkout.
set -euo pipefail
branch=$(git branch --show-current)
if [ "$branch" != "pilot/conformance" ]; then
  echo "reset-worktree: on branch '$branch', not pilot/conformance. Nothing changed." >&2
  exit 1
fi
git reset -q --hard pilot-fixtures-base
git clean -fdq
echo "reset-worktree: back at $(git rev-parse --short HEAD) (pilot-fixtures-base)"
git status --short
