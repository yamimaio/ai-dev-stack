#!/bin/bash
# Installs the pinned builder Claude Code as ~/ai-dev-stack-tools/claude-code/<version>/claude-pilot.
# A separate binary: it never touches your everyday `claude` (its install, settings, login or updates).
# Downloads the native macOS binary from the npm registry package @anthropic-ai/claude-code-darwin-arm64
# and checks it against the registry's sha512 for that version. Uses curl, openssl, base64 and tar.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/pins.env"
v="$CLAUDE_CODE_VERSION"
pkg="https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64"
dest="$HOME/ai-dev-stack-tools/claude-code/$v"
mkdir -p "$dest"
want=$(curl -fsSL "$pkg/$v" | grep -oE '"integrity" *: *"sha512-[^"]+"' | head -1 | sed -E 's/.*"sha512-([^"]+)"$/\1/')
[ -n "$want" ] || { echo "No version $v of @anthropic-ai/claude-code-darwin-arm64 on the npm registry." >&2; exit 1; }
tgz="$dest/pkg.tgz"
curl -fL --retry 3 -o "$tgz" "$pkg/-/claude-code-darwin-arm64-$v.tgz"
got=$(openssl dgst -sha512 -binary "$tgz" | base64 | tr -d '\n')
if [ "$got" != "$want" ]; then
  echo "Checksum mismatch against the npm registry. Stopping; nothing installed." >&2
  rm -f "$tgz"; exit 1
fi
tar -xzf "$tgz" -C "$dest" package/claude
# Its own name, so the network monitor (case E7) can tell it apart from your everyday claude.
mv "$dest/package/claude" "$dest/claude-pilot"
rmdir "$dest/package"
sha256=$(shasum -a 256 "$tgz" | awk '{print $1}')
rm "$tgz"
chmod +x "$dest/claude-pilot"
"$dest/claude-pilot" --version
echo "Installed $dest/claude-pilot (download sha256 $sha256, matched the registry's sha512)"
