---
description: Review an ai-dev-stack PR under the CLAUDE.md review policy
argument-hint: <PR URL> <round number>
---

Review this pull request: $ARGUMENTS (the PR URL, then the review round number).

1. Read CLAUDE.md and follow its REVIEW POLICY for this round. This session did not build the PR; if it did, stop and say so (SES-4).
   - **A Low that only corrects the PR's own body.** (REV-2).
   - **Bookkeeping, and a stale label over a correct value.** (REV-12).
   - **A round 3 or later that still has a High or Medium.** (REV-13).
2. **SES-14 review-worktree-at-the-head.** Review the PR head on GitHub, not a local branch (REV-3). Make a worktree at the PR head, `../ai-dev-stack-pr<N>`, N being the PR number, since step 3 reads the head's files from it. Make it with no branch, so the review leaves none behind: `git fetch origin pull/<N>/head`, then `git worktree add --detach ../ai-dev-stack-pr<N> FETCH_HEAD`. Any fetch run in between rewrites `FETCH_HEAD`, so then check that `git -C ../ai-dev-stack-pr<N> rev-parse HEAD` prints the PR's head, `gh pr view <N> --json headRefOid -q .headRefOid`. If it does not, remove the worktree and make it again. A review makes no local merge, so this is its only worktree and it stays at the head: step 3's `<head>` and `<dir>` are always its `HEAD` and its path. Run checks and scripts only where CLAUDE.md's THIS PROJECT says.
3. **REV-14 run-code-review-on-the-head.** Run /code-review on the PR head at high effort, without pushing changes. The fork does not start in the worktree, and its arguments are the one part of this session it is sure to see, so they carry the target, where to read the head's files, and where the git rule is. `<head>` is always `git -C ../ai-dev-stack-pr<N> rev-parse HEAD` and `<dir>` is always `../ai-dev-stack-pr<N>`, step 2's one worktree.
   - First, save `git branch --list --format='%(refname:short)'` from the main checkout. The format leaves out the `*` and `+` marks, which change when another session adds or removes a worktree.
   - Then run `git fetch origin`, so `origin/main` is current. Check that `gh pr view <N> --json headRefOid -q .headRefOid` still prints `<head>`. If it doesn't, the PR has moved: remove step 2's worktree, make it again at the new head as step 2 says, and take `<head>` from it again. Then run:
     `/code-review high origin/main...<head>, reading the head's files in <dir>; follow CLAUDE.md SESSION WORKFLOW on git state, (SES-10)`
   - **REV-15 branch-list-check.** Before posting the review, compare the saved list with a fresh one. In the summary comment, name each branch the fresh list adds or drops. For an added one, also give the last line of `git reflog show <branch>`, the command that made it: a parallel session's branches show up in the list too. The review deletes none of them.
   - The range needs no branch. Never give the PR number or URL: given a PR number, the fork fetches the head into a local branch.
   - If it starts subagents, give each a clear sub-goal and the same arguments.
   - **Forks and subagents change no git state.** (SES-10).
4. **REV-16 check-every-finding-yourself.** Check every finding yourself. Keep only those with a concrete failure scenario, or, for a design or code-quality finding, a named concrete future cost on code this PR adds or changes (REV-4, REV-6). Tag each [HIGH], [MEDIUM] or [LOW] (or recheck the tag it was given) by (REV-5), and (REV-12) for bookkeeping and for a stale label over a correct value. Drop anything you cannot verify or that is only taste. Also check the PR's closing lines against (BLD-3): an extra `Closes #M` whose evidence does not show #M fully resolved is a finding, and the line becomes `Refs #M`; an open issue the diff visibly resolves but the PR does not close is a finding too.
   - **REV-17 a-breach-of-the-builders-screens-is-a-finding.** A breach of any of these is a finding:
     - **The builder's screens.** Every item of (BLD-10).
     - **The builder's checks.** Every item of (BLD-19).
     - **One home per fact.** (BLD-16), and the id standard it rests on (GEN-24).
     - **Outside tools, the PR's and yours.** (GEN-20).
     - **A process ruling the PR body quotes but the rule text does not carry.** (BLD-15).
5. **A later round.** (REV-8).
   - **Repeated findings.** (GEN-22).
6. **REV-18 security-review-on-the-head.** A PR that (REV-11) names also runs `/security-review`. It takes no target and reads the checkout this session's shell is in, so: `git switch --detach <head>`, invoke `/security-review`, `git switch main` once it has echoed the diff, then check `git rev-parse --abbrev-ref HEAD` prints `main`. Paste the run's own `GIT STATUS` and `FILES MODIFIED` blocks in the review — `HEAD detached at <head>` with the PR's files is the run that happened, and `On branch main` with empty blocks is one whose "no findings" means nothing. That proof covers the diff it read and nothing else, so confirm every claim its report makes about a file's contents against `../ai-dev-stack-pr<N>` before repeating it in the review.
7. **REV-19 post-the-review.** Post the review on the PR with inline comments, and one summary line (REV-10): APPROVED, or CHANGES REQUESTED with what must be handled. Round 1 is APPROVED only when it found nothing at all (REV-7).
   - **A question the summary puts to the owner.** (GEN-17).
8. **Filing each new Low yourself, from round 2 on.** (REV-8).
   - **A Low that only corrects the PR's own body.** (REV-2).
9. **SES-15 review-cleanup.** After posting the review, remove every git worktree this session created: check `git worktree list` and run `git worktree remove` on each. Name the worktrees removed in a comment on the PR.
