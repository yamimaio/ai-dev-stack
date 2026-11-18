#!/bin/bash
# After a suite run: prints what Claude needs to score it, and appends it to
# ~/ai-dev-stack-runs/suite-<model-key>.log. Run from the scratch worktree.
# Usage: <ai-dev-stack>/suite/check-run.sh <case> <model-key> <run-number>
# Uses git, diff, ls and osascript only. Changes nothing in the worktree.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
case_id="${1:?usage: check-run.sh <case> <model-key> <run>}"
model="${2:?model-key}"; run="${3:?run number}"
exp="$here/fixtures/expected"
mkdir -p "$HOME/ai-dev-stack-runs"
{
echo "=== check-run $case_id model=$model run=$run at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "--- branch: $(git branch --show-current)  head: $(git rev-parse --short HEAD)"
echo "--- git status (anything listed was changed or created by the run)"
git status --short
echo "--- commits since the fixture commit"
git log --oneline pilot-fixtures-base..HEAD
case "$case_id" in
  T2|T4|T10)
    if diff -q "$exp/edit-target.$case_id.md" pilot-fixtures/edit-target.md >/dev/null; then
      echo "--- RESULT: edit-target.md matches the expected file exactly"
    else
      echo "--- RESULT: edit-target.md differs from expected (diff expected -> actual, tabs shown as ^I):"
      diff "$exp/edit-target.$case_id.md" pilot-fixtures/edit-target.md | cat -vet | head -40
    fi ;;
  T3)
    if [ -e pilot-fixtures/missing.md ]; then echo "--- RESULT: pilot-fixtures/missing.md was CREATED"; else echo "--- RESULT: no missing.md created"; fi ;;
  *)
    echo "--- diff (first 60 lines)"; git diff pilot-fixtures-base | head -60 ;;
esac
latest=$(ls -t "$HOME/.claude-pilot/projects"/*/*.jsonl 2>/dev/null | head -1)
echo "--- transcript: ${latest:-none found}"
[ -n "$latest" ] && osascript -l JavaScript "$here/transcript-summary.js" "$latest"
echo
} 2>&1 | tee -a "$HOME/ai-dev-stack-runs/suite-$model.log"
