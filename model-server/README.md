# Model server

llama.cpp `llama-server`, serving one model at a time on `127.0.0.1:8080`, with the Anthropic Messages API that Claude Code speaks. Host rule: this and Docker are the only things that run on the Mac. Everything here uses tools that ship with macOS (curl, shasum, tar, osascript).

| File | What it does |
|---|---|
| `pins.env` | llama.cpp release tag and SHA-256, and the server settings shared by every model. |
| `sampling.env` | Default sampling, the same for both candidates. **Inferred values; confirm on the model cards** (runbook step 3). |
| `models/<key>.env` | One per model: Hugging Face repo, quantization, the alias the server answers to. |
| `install-llama-cpp.sh` | Downloads the pinned release to `~/ai-dev-stack-tools/llama.cpp/<tag>/`. |
| `download-model.sh <key>` | Downloads the GGUF at a pinned Hugging Face commit to `~/ai-dev-stack-models/<key>/`, checks its SHA-256, writes `SOURCE.txt`. |
| `serve.sh <key>` | Starts the server with the pilot's flags; logs to `~/ai-dev-stack-runs/llama-server/`. |
| `json-pick.js` | Reads Hugging Face's JSON answers (osascript). |

## Models

| Key | Repo | Quant | Why |
|---|---|---|---|
| `qwen3.6-35b-a3b` | `unsloth/Qwen3.6-35B-A3B-GGUF` | Q4_K_M | Co-candidate (plan). Unsloth's GGUF is the one the research cites; plain Q4_K_M rather than their UD- dynamic quants, so both models use the same quant type. |
| `kat-coder-v2.5-dev` | `bartowski/Kwaipilot_KAT-Coder-V2.5-Dev-GGUF` | Q4_K_M | Co-candidate (plan); wins a tie. **Naming:** Kwaipilot's open weights are `KAT-Coder-V2.5-Dev`; "KAT-Coder-Pro V2.5" is their hosted model (web search, 2026-11-16: model pages on Hugging Face, OpenRouter, Vercel). No official Kwaipilot GGUF turned up; bartowski's is the most used community quant. *Inferred: the plan's "KAT-Coder-V2.5" means the -Dev weights.* |

Both are about 21 GB at Q4_K_M (research note `coding_models.md`). Fallbacks per the plan: Q5/Q6 of the stronger one, then Qwen3-Coder-30B-A3B; each would get its own `models/` file.

## Flags (llama.cpp `tools/server/README.md` at tag b12442)

- `-c 131072`: 128K, above the plan's 100K floor. Both models are trained to 262,144.
- `-np 1`: one slot, so the whole window serves the one session.
- `--cache-ram 16384`: prompt cache in RAM (default 8192 MiB), so Claude Code's small background requests do not cost the main conversation's cached prefix.
- `--port 8080`: stated, because the server's default is now 9931.
- `--jinja`: the model's own chat template (on by default; stated so the record shows it).
- `--metrics --log-timestamps --log-file`: evidence.
- Not set, on purpose: KV-cache quantization (default f16; one less variable, and 64 GB has room), speculative decoding / MTP (a speed change; later, with its own suite run), `--api-key` (loopback only).

Memory, inferred: about 21 GB of weights plus the KV cache, well inside 64 GB. The server log prints the real figures at start-up; they go in the setup record.

## Checks after starting

```
curl -s http://127.0.0.1:8080/health
curl -s http://127.0.0.1:8080/v1/models | head -c 400; echo
curl -s http://127.0.0.1:8080/v1/messages -H 'content-type: application/json' \
  -d '{"model":"x","max_tokens":32,"messages":[{"role":"user","content":"Reply with the word OK."}]}'; echo
```

**Prompt-cache check:** the server answers Anthropic requests with `cache_read_input_tokens` (`tools/server/server-task.cpp`), and Claude Code writes that into each transcript. `suite/check-run.sh` prints it per turn: on turn 2 of a session, cache_read should be most of the prompt. The server log's `prompt eval time = … / N tokens` lines show the same thing from the other side (N small on a cache hit).
