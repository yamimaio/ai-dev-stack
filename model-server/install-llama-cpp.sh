#!/bin/bash
# Installs the pinned llama.cpp release into ~/ai-dev-stack-tools/llama.cpp/<tag>/.
# Uses only curl, shasum and tar (all ship with macOS). Installs nothing system-wide.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/pins.env"
dest="$HOME/ai-dev-stack-tools/llama.cpp/$LLAMA_TAG"
url="https://github.com/ggml-org/llama.cpp/releases/download/$LLAMA_TAG/$LLAMA_ASSET"
mkdir -p "$dest"
tmp="$dest/$LLAMA_ASSET"
echo "Downloading $url"
curl -fL --retry 3 -o "$tmp" "$url" || {
  echo "Download failed. If the release has no macOS asset, tell Claude which tag https://github.com/ggml-org/llama.cpp/releases lists as newest with $LLAMA_ASSET's pattern." >&2
  exit 1
}
sum=$(shasum -a 256 "$tmp" | awk '{print $1}')
if [ -n "${LLAMA_SHA256:-}" ] && [ "$sum" != "$LLAMA_SHA256" ]; then
  echo "SHA-256 mismatch: got $sum, pinned $LLAMA_SHA256. Stopping." >&2
  exit 1
fi
tar -xzf "$tmp" -C "$dest" --strip-components 1
rm "$tmp"
"$dest/llama-server" --version 2>&1 | head -3
echo
echo "Installed to $dest"
echo "Paste this back to Claude (it goes into model-server/pins.env):"
echo "LLAMA_SHA256=$sum"
