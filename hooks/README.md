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

```
git push --dry-run origin HEAD:main     # expect: pre-push-block-main: refusing ...
git push --dry-run origin HEAD:some-branch   # expect: no refusal
git push --dry-run origin 'HEAD@{0 seconds ago}:refs/heads/main'   # expect: refusing (a rev with spaces)
```

Checked on git 2.43.0 with these steps: git hands the hook one line per ref, the local ref as it was typed (spaces included), and a non-zero exit stops the push; `--no-verify` skips the hook.
