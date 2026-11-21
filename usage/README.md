# Usage measurement

`session_usage.py` reads Claude Code's local session logs and writes one row per session with its token usage. It runs inside a Python container with no network and the logs mounted read-only, so no third-party code reads the logs and nothing leaves the machine. Only Docker runs on the host.

Use it whenever a usage comparison is needed: a baseline, a stage of a pilot, or the end of an iteration. Each run's tagged output is kept under `data/<project>/<run date>/`.

## Once per machine: keep logs long enough

Claude Code deletes transcripts older than `cleanupPeriodDays` (default 30) in a background sweep right after a session starts (Claude Code settings docs, `cleanupPeriodDays`). Before the first run, check the value:

```
grep cleanupPeriodDays ~/.claude/settings.json
```

If it prints nothing or a value below 90, the oldest logs may already be gone. Run the script first (next section), then add `"cleanupPeriodDays": 90` to `~/.claude/settings.json`. The minimum is 1; `0` fails validation.

Sessions started with `launcher/claude-pilot` keep their own logs and settings under `~/.claude-pilot` (see `launcher/README.md`).

## Each run

1. Make a folder for this run and copy the script in (replace the clone path if yours differs):

   ```
   mkdir -p ~/ai-dev-stack-runs/usage/$(date +%F) && cd ~/ai-dev-stack-runs/usage/$(date +%F)
   cp ~/Repos/ai-dev-stack/usage/session_usage.py .
   ```

2. Run it against the everyday Claude Code logs:

   ```
   docker run --rm --network none \
     -v "$HOME/.claude/projects:/logs:ro" \
     -v "$PWD:/work" -w /work \
     python:3.12-slim python -I session_usage.py /logs sessions.csv
   ```

   It prints the number of sessions and writes `sessions.csv` in this folder. For local-builder sessions, replace `$HOME/.claude/projects` with `$HOME/.claude-pilot/projects`.

3. Hand `sessions.csv` to Claude in the project thread. Claude tags each row by role (plan, build, fix, review) and issue, computes B and R per issue, and adds the run to `data/<project>/<run date>/` with a README stating the log window, the script version and any rows tagged by hand.

4. Sanity check: compare one week's total with the `/usage` 7-day bars in Claude Code. The units differ, so they won't match, but they should rise and fall together.

`--network none` means the container can reach nothing; `:ro` mounts the logs read-only.

## What a row holds

When the session ran, the first 80 characters of its first prompt (built-in commands such as `/clear` and `/model` skipped), the commands and issue/PR numbers it touched, the Claude models used, and token counts by type, with subagents included and also shown separately. A `weighted` column gives a rough relative cost, so a build can be compared with a review. Sessions on non-Claude models are left out (only `claude-*` models count).

## Tagging rules

- Fix pushes made in the builder's session count as build (B).
- A session that doesn't start with its command (`/build-issue N`, `/review-pr N`) can't be tagged from its first prompt; it is tagged by hand and listed in that run's README. Starting each session with the command first avoids this.

## If it prints 0 sessions

The log format changed. The script was written against the format of 2026-11 (one JSON object per line, usage repeated per content block and de-duplicated by message id and request id, subagent logs under `<session>/subagents/`). Ask Claude to adjust it.
