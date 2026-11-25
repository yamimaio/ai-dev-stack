#!/bin/bash
# Starts llama-server for one model with the pilot's fixed flags. Leave it running in its own terminal.
# Usage: model-server/serve.sh <model-key>
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
key="${1:?usage: serve.sh <model-key>  (see model-server/models/)}"
. "$here/pins.env"
. "$here/sampling.env"
# shellcheck source=/dev/null  # the model file is picked at run time
. "$here/models/$key.env"
bin="$HOME/ai-dev-stack-tools/llama.cpp/$LLAMA_TAG/llama-server"
dir="$HOME/ai-dev-stack-models/$key"
[ -x "$bin" ] || { echo "No llama-server at $bin. Run model-server/install-llama-cpp.sh first." >&2; exit 1; }
# First file in sort order: the model, or shard 00001 of a split model.
model=$(ls "$dir"/*.gguf 2>/dev/null | sort | head -1 || true)
[ -n "$model" ] || { echo "No GGUF in $dir. Run model-server/download-model.sh $key first." >&2; exit 1; }
logs="$HOME/ai-dev-stack-runs/llama-server"; mkdir -p "$logs"
log="$logs/$key-$(date +%Y%m%d-%H%M%S).log"
echo "Model: $model"
echo "Alias: $ALIAS   Port: $LLAMA_PORT   Context: $LLAMA_CTX   Log: $log"
# Flags, each one on purpose (llama.cpp tools/server/README.md at $LLAMA_TAG):
#   --host 127.0.0.1      loopback only (also the default)
#   --port                fixed, so the launcher knows where to point (the default changed to 9931)
#   -c                    128K window: the plan asks for 100K+, Claude Code's prompt is long
#   -np 1                 one slot, so the whole window serves the one session
#   --cache-ram           RAM prompt cache, so background requests do not cost the main prefix
#   --jinja               use the model's own chat template (default is on; stated so the record shows it)
#   --temp/top-p/top-k/min-p   defaults when a request does not set them (sampling.env)
#   --metrics, --log-timestamps, --log-file   evidence for the ledger and the cache check
exec "$bin" -m "$model" --alias "$ALIAS" \
  --host "$LLAMA_HOST" --port "$LLAMA_PORT" \
  -c "$LLAMA_CTX" -np 1 --cache-ram "$LLAMA_CACHE_RAM_MIB" --jinja \
  --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" \
  --metrics --log-timestamps --log-file "$log"
