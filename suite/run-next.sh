#!/bin/bash
# Runs the next suite session for one model: resets the scratch worktree, shows what to answer,
# starts the builder on the case's prompt, then records the result for scoring.
# Usage: ~/Repos/ai-dev-stack/suite/run-next.sh <model-key>        (run the same line again for the next one)
# Progress: ~/ai-dev-stack-runs/progress-<model-key>.txt   Log for Claude: ~/ai-dev-stack-runs/suite-<model-key>.log
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
model="${1:?usage: run-next.sh <model-key>}"
runs="$HOME/ai-dev-stack-runs"
[ -f "$runs/project.env" ] || { echo "No $runs/project.env. Do the runbook's worktree step first." >&2; exit 1; }
. "$runs/project.env"     # PROJECT, WORKTREE
proj="$here/projects/$PROJECT"
progress="$runs/progress-$model.txt"; touch "$progress"

# 19 sessions (T8 and T9 share one), run 1 of each, then run 2, then run 3.
cases="T1 T2 T3 T4 T5 T6 T7 T8 T10 T11 T12 E1 E2 E3 E4 E5 E6 E8"
next=""; n_done=$(wc -l < "$progress" | tr -d ' ')
for run in 1 2 3; do
  for c in $cases; do
    grep -qx "$c $run" "$progress" || { next="$c $run"; break 2; }
  done
done
[ -n "$next" ] || { echo "All 54 sessions for $model are done. Paste the log to Claude (see runbook)."; exit 0; }
set -- $next; c=$1; run=$2

file_for() { if [ -f "$here/$1/$2.txt" ]; then echo "$here/$1/$2.txt"; else echo "$proj/$1/$2.txt"; fi; }
prompt_file=$(file_for prompts "$c"); [ "$c" = T8 ] && prompt_file="$here/prompts/T8a.txt"
hint=$(cat "$(file_for hints "$c")")

cd "$WORKTREE" || exit 1
"$here/reset-worktree.sh" >/dev/null || exit 1
# E5 needs a change to commit.
[ "$c" = E5 ] && echo "E5 change" >> pilot-fixtures/edit-target.md

clear
echo "=============================================================="
echo " $model   case $c   run $run   ($n_done of 54 done)"
echo "=============================================================="
echo " When Claude Code asks permission:  $hint"
if [ "$c" = T8 ]; then
  echo
  echo " This session has extra steps. When the first answer is done, paste these one at a time:"
  echo "   1. $(cat "$here/prompts/T8b.txt")"
  echo "   2. $(cat "$here/prompts/T9-filler.txt")"
  echo "   3. /context      (if it shows less than 60k tokens used, paste line 2 again, then /context)"
  echo "   4. $(cat "$proj/prompts/T9.txt")"
fi
echo
echo " When it has finished, type /exit"
echo "=============================================================="
read -r -p " Press Enter to start. " _

"$here/../launcher/claude-pilot" "$(cat "$prompt_file")"

if [ "$c" = T8 ]; then
  "$here/check-run.sh" T8 "$model" "$run" >/dev/null
  "$here/check-run.sh" T9 "$model" "$run" >/dev/null
else
  "$here/check-run.sh" "$c" "$model" "$run" >/dev/null
fi
echo "$c $run" >> "$progress"
echo
echo "Recorded $c run $run ($((n_done + 1)) of 54 sessions done). Run the same command again for the next one."
