# Stage 0 check: does /review-pr run in a scratch repo unchanged?

Pilot material, not Gravity work. Drafted 2026-11-12. It answers one open question before Stage 2: the replays run in a scratch repo, so `/review-pr` has to work there without edits.

What is already known: `.claude/commands/review-pr.md` on `main` (`0234f0c`) never names `yamimaio/gravity`. It works through `origin`, `gh pr view <N>`, `git fetch origin pull/<N>/head`, a `../gravity-pr<N>` worktree and `scripts/stack-down.sh`. So it should work. Only a real run confirms it.

**Use a plain private copy, not a GitHub fork.** In a fork, `gh` tends to send PR commands to the parent repo, and a replay review could then land on the real Gravity PRs.

Cost: about 15 minutes, plus one small review's worth of Claude usage. You run every step yourself.

## Steps

1. On GitHub, create a new **private** repo, for example `yamimaio/gravity-pilot`. Not a fork. Leave it empty.
2. In a new folder outside your normal Gravity checkout:
   ```
   git clone https://github.com/yamimaio/gravity gravity-pilot
   cd gravity-pilot
   git remote set-url origin https://github.com/yamimaio/gravity-pilot
   git remote -v        # both lines must show gravity-pilot before you push
   git push -u origin main
   gh repo set-default yamimaio/gravity-pilot
   ```
3. In the new repo's GitHub settings, turn **Actions off**. The pilot uses `scripts/ci-local.sh` in the container instead, and this spends no Actions minutes.
4. Make a tiny PR there, for example a one-word fix in a doc, and push it. It will be PR #1.
5. Start a fresh local Claude Code session in the `gravity-pilot` folder and run `/review-pr 1`.
6. Check four things:
   - a. The review and its summary comment appear on **gravity-pilot** PR #1, and nothing appears on `yamimaio/gravity`.
   - b. It made `../gravity-pr1` at the PR head, and `/code-review` ran.
   - c. The cleanup step ran `scripts/stack-down.sh gravity-pr1` and removed the worktree.
   - d. Nothing failed because of a repo name.
7. Report what happened in the pilot thread.
   - All four pass: the answer is "yes, unchanged", and replays stay in Stage 2.
   - Something breaks: paste the error. We then decide whether a small launcher-side tweak fixes it or whether replays become the first forward builds, as the plan already allows.

## Cautions

- Keep this folder separate from your real checkout, so no Gravity session ever starts there by mistake.
- Keep the scratch repo for Stage 2. The replays run there, from each old PR's fork point.

## Result (Yami ran it, 2026-11-16)

Passed, all four checks confirmed: `/review-pr 1` ran unchanged in `yamimaio/gravity-pilot`, so replays stay in Stage 2.

- a. Review posted on gravity-pilot PR #1 (round 1, changes requested). Nothing on `yamimaio/gravity`: the only Gravity change in that window was #672, which Yami made herself (2026-11-16).
- b. Worktree at the PR head `d937efc`, `.env` for `gravity-pr1`, `/code-review high` ran (3 min 8 s, no code findings).
- c. `scripts/stack-down.sh gravity-pr1` ran, exit 0; branch list unchanged. Worktree removed: `git worktree list` shows only `main` (Yami, 2026-11-16).
- d. Nothing failed on a repo name.

What it taught us for Stage 2:

- **Issues don't come with a clone.** The scratch repo has none, so the review's HIGH was "no `Closes #N`, no issue exists". Each replay must first copy its Gravity issue (and plan comment) into gravity-pilot and reference the new number, or every replay gets the same HIGH.
- **Actions are off, so `decision-ids` never runs there.** The review flagged that as a MEDIUM. Gravity's Opus controls had it running, so replay reviews would see a gap the control didn't. To decide before Stage 2: turn Actions on in gravity-pilot for the replays, or note the gap in each replay's ledger row.
- **Self-review downgrade.** GitHub refuses REQUEST_CHANGES on your own PR, so the verdict went out as a COMMENTED review with the verdict line in its body. Inferred to be the same in Gravity whenever the PR author and the `gh` user match, so not an arm difference.
