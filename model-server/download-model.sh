#!/bin/bash
# Downloads one model's GGUF at a pinned Hugging Face commit and checks its SHA-256.
# Usage: model-server/download-model.sh <model-key>     (keys: files in model-server/models/)
# Uses curl, shasum and osascript (all ship with macOS).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
key="${1:?usage: download-model.sh <model-key>  (see model-server/models/)}"
# shellcheck source=/dev/null  # the model file is picked at run time
. "$here/models/$key.env"
dest="$HOME/ai-dev-stack-models/$key"
mkdir -p "$dest"
api="https://huggingface.co/api/models/$HF_REPO"
meta="$dest/.hf-meta.json"; tree="$dest/.hf-tree.json"

curl -fsSL "$api/revision/main" -o "$meta"
rev=$(osascript -l JavaScript "$here/json-pick.js" "$meta" sha)
curl -fsSL "$api/tree/$rev?recursive=true" -o "$tree"

if [ -n "${QUANT_FILE:-}" ]; then
  pattern="^${QUANT_FILE//./\\.}\$"
else
  pattern="-${QUANT}(-[0-9]{5}-of-[0-9]{5})?\\.gguf\$"
fi
matches=$(osascript -l JavaScript "$here/json-pick.js" "$tree" files "$pattern" | grep -v 'UD-' || true)
if [ -z "$matches" ]; then
  echo "No $QUANT file found in $HF_REPO at $rev. Files there:" >&2
  osascript -l JavaScript "$here/json-pick.js" "$tree" files '\.gguf$' >&2
  exit 1
fi
# More than one file is fine only if they are shards of one split model.
n_all=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')
n_split=$(printf '%s\n' "$matches" | grep -cE -- '-[0-9]{5}-of-[0-9]{5}\.gguf' || true)
if [ "$n_all" -gt 1 ] && [ "$n_all" != "$n_split" ]; then
  echo "More than one $QUANT file; set QUANT_FILE in model-server/models/$key.env to one of:" >&2
  printf '%s\n' "$matches" | cut -f1 >&2
  exit 1
fi

record="$dest/SOURCE.txt"
{
  echo "model_key=$key"
  echo "hf_repo=$HF_REPO"
  echo "hf_revision=$rev"
  echo "quant=$QUANT"
  echo "alias=$ALIAS"
  echo "downloaded=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$record"

printf '%s\n' "$matches" | while IFS="$(printf '\t')" read -r path sha size; do
  name="$(basename "$path")"
  echo "Downloading $name ($((size / 1000000)) MB) at $rev"
  curl -fL --retry 3 -C - -o "$dest/$name" "https://huggingface.co/$HF_REPO/resolve/$rev/$path"
  got=$(shasum -a 256 "$dest/$name" | awk '{print $1}')
  if [ "$got" != "$sha" ]; then
    echo "SHA-256 mismatch for $name: got $got, Hugging Face lists $sha. Delete the file and re-run." >&2
    exit 1
  fi
  echo "file=$name sha256=$sha bytes=$size" >> "$record"
done
rm -f "$meta" "$tree"
echo
echo "Verified. Paste this back to Claude (it goes into the setup record):"
cat "$record"
