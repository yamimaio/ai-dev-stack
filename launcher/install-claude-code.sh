#!/bin/bash
# Installs the pinned builder Claude Code as ~/ai-dev-stack-tools/claude-code/<version>/claude-pilot.
# It never touches your everyday `claude` (its install, settings, login or auto-updates).
# Uses curl, shasum and tar only; no npm or Node on the host.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/pins.env"
dest="$HOME/ai-dev-stack-tools/claude-code/$CLAUDE_CODE_VERSION"
mkdir -p "$dest"
tgz="$dest/pkg.tgz"
curl -fL --retry 3 -o "$tgz" "$CLAUDE_CODE_TGZ_URL"
sum=$(shasum -a 256 "$tgz" | awk '{print $1}')
if [ "$sum" != "$CLAUDE_CODE_TGZ_SHA256" ]; then
  echo "SHA-256 mismatch: got $sum, pinned $CLAUDE_CODE_TGZ_SHA256. Stopping." >&2
  exit 1
fi
tar -xzf "$tgz" -C "$dest" package/claude
# Its own name, so the network monitor (case E7) can tell it apart from your everyday claude.
mv "$dest/package/claude" "$dest/claude-pilot"
rmdir "$dest/package"; rm "$tgz"
chmod +x "$dest/claude-pilot"
"$dest/claude-pilot" --version
echo "Installed $dest/claude-pilot"
