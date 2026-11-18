#!/bin/bash
# Prints the sampling lines (temperature, top_p, top_k, min_p, penalties) from each model's
# original model card on Hugging Face, so they can be checked against sampling.env.
# Usage: model-server/show-sampling.sh        Uses curl and grep.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
for f in "$here"/models/*.env; do
  CARD_REPO=""; . "$f"
  echo "=== $(basename "$f" .env): https://huggingface.co/$CARD_REPO"
  curl -fsSL "https://huggingface.co/$CARD_REPO/raw/main/README.md" \
    | grep -n -i -E 'temperature|top[_ -]?p|top[_ -]?k|min[_ -]?p|presence|repetition' | head -25 \
    || echo "(no sampling lines found, or the card could not be fetched)"
done
echo "=== sampling.env now:"; grep -E '^[A-Z_]+=' "$here/sampling.env"
