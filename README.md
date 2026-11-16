# ai-dev-stack

How Yami builds software with AI across her projects, versioned. The setup evolves through iterations; each one tests one change and records what it teaches.

This repo holds the parts that run or get reused: the local-builder launcher, the model-server commands, the conformance suite, the git guards, the usage script, the run ledger, and the research behind each iteration. Project repos (Gravity first) stay untouched; each project gets one small per-project file here.

## Layout

| Path | What it holds |
|---|---|
| `launcher/` | Project-neutral launcher for a Claude Code session on a local model: env vars, deny-rule settings, the Claude Code pin. A launcher commit is the setup version a ledger row records. |
| `model-server/` | `llama-server` commands and per-model notes (model file, quantization, template, flags). |
| `suite/` | Stage 1 conformance suite: generic cases in `conformance-suite.md`, one file per project in `projects/`, fixtures, run results. |
| `hooks/` | Git guards, such as `pre-push-block-main`. |
| `usage/` | `session_usage.py` (reads Claude Code session logs in a no-network container) and its tagged data per project. |
| `ledger/` | The run ledger: one row per build, both arms. |
| `checks/` | One-off checks, such as the scratch-repo review check. |
| `pages/` | Sources of published tool pages, such as the PR minutes log. |
| `docs/iterations/` | One folder per iteration: what it tests, its plan link, and its research snapshot. |

## Living records (not copied here)

Each iteration has its own plan, kept as a living doc and linked from its row in the Iterations table below. This repo links them rather than copying them.

- PR minutes log: https://claude.ai/artifact/VpY2wfUzTbZKWGmixztLr7 (source: `pages/minutes-log.html`)

## Rules that apply to everything here

- **Host rule:** on the Mac host only the model server and Docker run (plus git and Claude Code itself). Scripts here run in a container unless their README says otherwise.
- **Nothing here is Gravity work:** no Gravity D rows, ADRs or issues come from this repo unless Yami asks.
- **Re-run rule:** any change to runtime, model, quantization, chat template, launcher settings or Claude Code version needs a conformance-suite run before the next build counts (`suite/conformance-suite.md`).
- **Branch protection on `main`** only once the repo is public (GitHub free plan; Yami, 2026-11-16). Until then: PRs by habit, plus `hooks/pre-push-block-main` if installed.

## Iterations

| # | Change tested | Where |
|---|---|---|
| 1 | Local model builder pilot: Claude plans, a local model builds, Claude reviews | `docs/iterations/01-local-builder/`, [plan](https://claude.ai/artifact/7xTZjhynpcqCnJiaw2PjHp) |

## Licence

MIT, see `LICENSE`.
