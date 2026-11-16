# Git guards

## `pre-push-block-main`

Refuses any `git push` whose target is `main` on the remote, however the command is spelled (`main`, `HEAD:main`, `+main`, a force-push). It is the guard for the period before GitHub branch protection is available (free plan, private repos; Yami, 2026-11-16).

It can be skipped with `git push --no-verify`, so the launcher's settings also deny `--no-verify` (see `launcher/settings.json`).

### Install (Yami runs this; a git hook runs on the host through git, no other tools)

In the clone the builder works in (hooks live in the shared `.git`, so every worktree of that clone gets it):

```
cp ~/code/ai-dev-stack/hooks/pre-push-block-main "$(git rev-parse --git-common-dir)/hooks/pre-push"
chmod +x "$(git rev-parse --git-common-dir)/hooks/pre-push"
```

- This also stops your own pushes to `main` from that clone. Inferred: fine, since changes land through PRs.
- If the repo sets `core.hooksPath` (Husky and similar do), git ignores `.git/hooks`. Check first with `git config core.hooksPath`; if it prints a path, put the hook there instead or tell Claude.
- Uninstall: `rm "$(git rev-parse --git-common-dir)/hooks/pre-push"`.

### Test it (safe: `--dry-run` sends nothing, but still runs the hook)

```
git push --dry-run origin HEAD:main     # expect: pre-push-block-main: refusing ...
git push --dry-run origin HEAD:some-branch   # expect: no refusal
```

Source for hook behaviour: git-scm.com/docs/githooks ("pre-push": runs during `git push`, after the remote status is checked; a non-zero exit stops the push; `--no-verify` skips it).
