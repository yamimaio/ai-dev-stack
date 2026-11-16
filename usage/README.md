# Stage 0 usage baseline: how to run it

Pilot material, not Gravity work. Decided by Yami on 2026-11-12 (option B): a small script of ours reads Claude Code's local session logs inside a container that has no network, so no third-party code reads the logs and nothing can leave the Mac.

## Order: run first, then raise retention

1. **Run the script (below) before you next open Claude Code.** Claude Code deletes transcripts older than `cleanupPeriodDays` (default 30) in a silent background sweep right after a session starts (Claude Code settings reference, `cleanupPeriodDays`, https://code.claude.com/docs/en/settings-reference.md). Any launch therefore removes the oldest October sessions first.
2. **Then set `"cleanupPeriodDays": 90`** in `~/.claude/settings.json` (Yami, 2026-11-12). That keeps milestone 2's Opus builds and the pilot's own sessions readable until the pilot's final comparison, so the script can be re-run (a fix after the `/usage` check, a new column, a disputed number). The minimum is 1, and `0` fails validation. Lower it again after the pilot if you like.

## Run it

From a folder of your choice on the Mac (not inside a Gravity checkout), with `session_usage.py` copied into it. Get it from this repo: `usage/session_usage.py`; no other files needed:

```
docker pull python:3.12-slim
docker run --rm --network none \
  -v "$HOME/.claude/projects:/logs:ro" \
  -v "$PWD:/work" -w /work \
  python:3.12-slim python -I session_usage.py /logs sessions.csv
```

- `--network none`: the container cannot reach anything.
- `:ro`: the logs are mounted read-only.
- Only Docker runs on the Mac; no node, npm, npx or Python on the host.

It prints the number of sessions and writes `sessions.csv` next to the script.

## What you get

One row per Claude Code session: when it ran, the first 80 characters of its first prompt (so `/build-issue 575` and `/review-pr 580` are easy to spot), the Claude models used, and token counts by type, with subagents included and also shown separately. A `weighted` column gives a rough relative cost so a build can be compared with a review. Local-model sessions are left out automatically (only `claude-*` models count).

## Then

1. Tag each row you can by role (plan, build, fix, review) and issue, using `commands` (e.g. `/build-issue 575`, `/review-pr 639`), `refs` (the issue and PR numbers the session touched most), `first_prompt` and the dates. A /clear starts a new log, so `first_prompt` skips built-in commands such as /clear and /model (script fixed 2026-11-13; the first run showed /clear for most rows). Fix pushes made in the builder's session count as build (B), as ruled on 2026-11-12.
2. Sanity check: compare one week's total with the `/usage` 7-day bars in Claude Code. They will not match exactly (different units), but they should rise and fall together.
3. Share the CSV, or only the tagged totals, in the pilot thread. B/R comes from those.

Tested on 2026-11-12 against a current Claude Code session log (format: one JSON object per line; usage repeated per content block, de-duplicated by message id and request id; subagent logs under `<session>/subagents/`). If your Claude Code version writes a different format, the script prints 0 sessions: tell me and I will adjust it.

## Data

Tagged output per project lives in `data/<project>/` (`sessions-tagged.csv`, `issues-br.csv`). `sessions-tagged.csv` holds the first 80 characters of each session's first prompt: review it before this repo is ever made public.

Local-builder sessions launched with `launcher/` write their transcripts under that launcher's own config folder (see `launcher/README.md`), not `~/.claude/projects`. The script leaves local-model sessions out anyway; point it at that folder only for ledger evidence.

## Known tagging exceptions

Sessions that won't tag from their first prompt or commands. Tag these by hand on the next run.

- **Issue #505, build session (2026-11-13, reported by Yami):** the session opened with a pasted "Reminder:" block of rules that aren't implemented yet, not with `/build-issue 505`. Tag it role = build, issue = 505. From now on Yami starts each session with the command first.
