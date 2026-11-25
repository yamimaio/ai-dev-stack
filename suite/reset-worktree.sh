#!/bin/bash
# Resets the scratch worktree between runs (suite "How to run"). Run from the scratch worktree.
# Goes back to the fixture commit (local tag pilot-fixtures-base), dropping edits, any new
# untracked file (git-ignored ones such as .env stay), and any commit a run made (case E5).
# Refuses unless it runs in the scratch worktree that project.env names, and git's worktree root is
# that same folder (a core.worktree setting could point it at a real checkout). If a run left the
# worktree on another branch or a detached HEAD (E5 may create a branch), it goes back to
# pilot/conformance and deletes that branch first.
set -euo pipefail
runs="$HOME/ai-dev-stack-runs"
[ -f "$runs/project.env" ] || { echo "reset-worktree: no $runs/project.env. Nothing changed." >&2; exit 1; }
. "$runs/project.env"
[ "$PWD" = "$WORKTREE" ] || { echo "reset-worktree: here is $PWD, not the scratch worktree $WORKTREE. Nothing changed." >&2; exit 1; }
[ "$(git rev-parse --show-toplevel)" = "$PWD" ] || { echo "reset-worktree: git's worktree root is $(git rev-parse --show-toplevel), not $PWD (check core.worktree). Nothing changed." >&2; exit 1; }
git rev-parse -q --verify pilot-fixtures-base >/dev/null || { echo "reset-worktree: no local pilot-fixtures-base tag. Nothing changed." >&2; exit 1; }
branch=$(git branch --show-current)
if [ "$branch" != "pilot/conformance" ]; then
  echo "reset-worktree: the run left this worktree on '${branch:-a detached HEAD}'. Going back to pilot/conformance." >&2
  git switch -q -f pilot/conformance
  [ -n "$branch" ] && git branch -q -D "$branch"
fi
git reset -q --hard pilot-fixtures-base
git clean -fdq
echo "reset-worktree: back at $(git rev-parse --short HEAD) (pilot-fixtures-base)"
git status --short
