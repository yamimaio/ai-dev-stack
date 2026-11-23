# Git guards

## `pre-push-block-main`

Refuses any `git push` whose target is `main` on the remote: `main`, `HEAD:main`, `+main`, a force-push, or a source rev with spaces in it such as `HEAD@{1 hour ago}:main`.

**Where it earns its place:** a clone whose remote has no server-side protection on `main`, such as a private repo on GitHub's free plan. That is Gravity's clone today. On ai-dev-stack it is redundant: the repo is public, and a GitHub ruleset on `main` already requires a PR and blocks force pushes and deletion. It is kept in this repo for those other clones. What it still adds anywhere is a local refusal, before any objects reach the server.

**What it costs to keep:** it is one of three copies of the rule "never push to `main`", along with Claude Code's deny rule and the server's ruleset, and the weakest of the three. It parses a line format git defines, so a change to that format, or a new way of spelling a ref, can open a gap; re-run the test below after any edit. It also stops working, without a warning, if the repo sets `core.hooksPath` (see Install).

It can be skipped with `git push --no-verify`, so Claude Code's settings deny `--no-verify`: this repo's `.claude/settings.json` for sessions in this repo, and `launcher/settings.json` for the pilot's builder.

### Install (the user runs this; a git hook runs on the host through git, no other tools)

In the clone the builder works in (hooks live in the shared `.git`, so every worktree of that clone gets it):

```
cp ~/Repos/ai-dev-stack/hooks/pre-push-block-main "$(git rev-parse --git-common-dir)/hooks/pre-push"
chmod +x "$(git rev-parse --git-common-dir)/hooks/pre-push"
```

- This also stops your own pushes to `main` from that clone. Inferred: fine, since changes land through PRs.
- If the repo sets `core.hooksPath` (Husky and similar do), git ignores `.git/hooks`. Check first with `git config core.hooksPath`; if it prints a path, put the hook there instead or tell Claude.
- Uninstall: `rm "$(git rev-parse --git-common-dir)/hooks/pre-push"`.

### Test it (safe: `--dry-run` sends nothing, but still runs the hook)

Run it from a throwaway branch with one empty commit. Git skips a ref that is already up to date before it calls the hook, so from a clone whose `HEAD` equals `origin/main` a plain `git push --dry-run origin HEAD:main` prints `Everything up-to-date` and tests nothing. `--force` keeps a clone that is behind `origin/main` from being rejected before the hook runs.

```
git switch -c hook-test && git commit --allow-empty --only -m "hook test"
git push --dry-run --force origin HEAD:main                              # expect: pre-push-block-main: refusing ...
git push --dry-run --force origin 'HEAD@{0 seconds ago}:refs/heads/main' # expect: refusing (a rev with spaces)
git push --dry-run origin :refs/heads/main                               # expect: refusing (a deletion)
git push --dry-run origin HEAD:some-branch                               # expect: no refusal
git switch - && git branch -D hook-test
```

Checked on git 2.43.0 with these steps, from a clone equal to `origin/main` and from one behind it: each `main` line refuses with exit 1, the side branch passes, and the remote's `main` is unchanged afterwards.
