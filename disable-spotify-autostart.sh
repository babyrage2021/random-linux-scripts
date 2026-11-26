#!/usr/bin/env bash
#
# disable-spotify-autostart.sh
# Disable any existing Spotify autostart entries so the built-in
# "start minimized" setting in the Spotify app can take effect.
#
# Usage:
#   bash disable-spotify-autostart.sh

set -euo pipefail

AUTOSTART="${HOME}/.config/autostart"

echo "==> Looking for Spotify autostart entries in $AUTOSTART"

found=0
shopt -s nullglob
for f in "$AUTOSTART"/spotify*.desktop; do
  if [[ -f "$f" ]]; then
    echo "    Found: $f"
    mv -v "$f" "${f}.disabled"
    found=1
  fi
done
shopt -u nullglob

if [[ $found -eq 0 ]]; then
  echo "    No Spotify autostart .desktop files found."
else
  echo
  echo "Disabled. Renamed to *.disabled so they won't start."
fi

echo
echo "Now:"
echo "  1. Open Spotify"
echo "  2. Go to Settings → Startup and window behaviour"
echo "  3. Set 'Open Spotify automatically after you log into the computer' to Minimized"
echo
echo "To re-enable later, rename the .disabled files back to .desktop"
