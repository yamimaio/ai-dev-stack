# Launcher

Why a separate Claude Code for the builder: your everyday `claude` keeps auto-updating, and the conformance suite clears one exact version (re-run rule). A separate binary stays on that version, gets its own name (`claude-pilot`, so the network check can single it out) and its own config dir (its transcripts and settings stay apart from yours). You start it with `claude-pilot` instead of `claude`, only for local-model builder sessions.

Starts a pinned, separate Claude Code on the local model server. Project-neutral: it knows nothing about any project; a project's own `.claude/settings.json` still loads and its deny rules add to these.

| File | What it does |
|---|---|
| `pins.env` | The builder's Claude Code version. A change here is a setup change (quick re-run). |
| `install-claude-code.sh` | Puts the pinned binary at `~/ai-dev-stack-tools/claude-code/<version>/claude-pilot`, checked against the npm registry's sha512 for that version. curl, openssl, tar; no npm. |
| `claude-pilot` | The launcher. Run from the worktree to build in. |
| `settings.json` | Passed with `--settings`: the generic deny rules and the 90-day log retention. |

## What the launcher sets, and why

Sources: Claude Code docs at code.claude.com, read 2026-11-16 (the docs track the newest release, 2.1.325; every item below has no version note above 2.1.311 unless stated). Pages: "Environment variables" (env-vars), "Settings" (settings), "Configure permissions" (permissions), "Model configuration" (model-config), "LLM gateway protocol" (llm-gateway-protocol), "Advanced setup" (setup).

- `CLAUDE_CONFIG_DIR=~/.claude-pilot`: its own settings and history, so the builder never touches `~/.claude`. It has no claude.ai login at all and needs none: with a token set and a non-Anthropic base URL, requests carry that token instead of a subscription login (llm-gateway), so the builder uses none of the subscription. Planning and review stay in your everyday `claude`, on your account as before (env-vars, `CLAUDE_CONFIG_DIR`). **Builder transcripts land in `~/.claude-pilot/projects`, not `~/.claude/projects`.** The ledger, the cache check and E7 read them from there, and the usage script must be pointed there for local-arm sessions.
- `cleanupPeriodDays: 90` in `settings.json`, because the 90-day setting you made on 2026-11-13 lives in `~/.claude/settings.json`, which this config dir does not read.
- `ANTHROPIC_BASE_URL` to the local server, `ANTHROPIC_AUTH_TOKEN` a dummy, `ANTHROPIC_API_KEY` unset: requests carry that token instead of a subscription login (llm-gateway).
- `ANTHROPIC_MODEL`, `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU,FABLE}_MODEL`, `CLAUDE_CODE_SUBAGENT_MODEL` all set to the served alias: background calls go to the Haiku alias and subagents can pick a model, so every name must resolve to the one served model (env-vars; case T12).
- `CLAUDE_CODE_MAX_CONTEXT_TOKENS` = the served window (131072). An unrecognised model id that does not start with `claude-` takes it directly (model-config, "Correct the window for a gateway or custom model ID").
- `CLAUDE_CODE_ATTRIBUTION_HEADER=0`: keeps the attribution block out of the prompt. **Confirmed new fact:** since v2.1.181 the block is stable for a whole conversation on a custom base URL, so it no longer breaks the server's cache by itself (llm-gateway-protocol, "System prompt attribution block"). Kept anyway, as ruled; it costs nothing.
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`: strips pre-release request fields a non-Anthropic server may reject (env-vars).
- `DISABLE_AUTOUPDATER=1`, `DISABLE_UPDATES=1`: no background or manual update of the pin (env-vars; setup, "Disable auto-updates"). The binary also lives outside every updater's path.
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`, `DISABLE_TELEMETRY=1`, `DISABLE_ERROR_REPORTING=1`: no telemetry, error reports, release notes or feature-flag fetches (env-vars). Case E7 checks it on the wire.

## Deny rules (`settings.json`)

Ruled 2026-11-13: narrow rules, not a blanket `git push*` deny. Rules from every settings level are combined, so a project's own rules still apply (settings, "Settings precedence": list keys combine). Pattern semantics from permissions, "Wildcard patterns".

| Guard | Rules | Note |
|---|---|---|
| `docker … prune` | `docker * prune`, `docker * prune *` | Two rules because a rule with two `*` does not match the bare form. |
| Push to `main` | `git push * main`, `… main *`, `*:main`, `*:main *`, `*refs/heads/main*` | Catches `origin main`, `-u origin main`, `HEAD:main`. A bare `git push` while on `main` is not visible in the text: the pre-push hook (`hooks/`) or the scratch worktree's dead push URL holds that. |
| Force-push | `*--force*`, `-f*`, `* -f`, `* -f *`, `* +*` | `+refspec` is a force-push too. |
| Skipping hooks | `git *--no-verify*` | So `hooks/pre-push-block-main` cannot be bypassed. Added at the repo thread's request; same family as the ruled guards. |
| Shell wrappers | `bash -*c *`, `sh -*c *`, `zsh -*c *`, and `/bin/` forms | `-*c` also catches `-lc`. It can also block a rare harmless `bash -x script c`; acceptable. |

Not covered by text rules, by design: `git -C . push`, `git -c … push`, `eval`, a full path to `npm`, a script that runs `node`. The docs say so plainly ("What a Bash rule doesn't match"); E3 tests the model on those.

## Daily use

```
cd <worktree>
~/code/ai-dev-stack/launcher/claude-pilot                      # interactive
~/code/ai-dev-stack/launcher/claude-pilot "$(cat prompt.txt)"  # interactive, first prompt from a file
```

It prints one line with the Claude Code version, served model, llama.cpp tag and launcher commit: that line goes in the setup record.
