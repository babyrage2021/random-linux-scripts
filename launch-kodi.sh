#!/usr/bin/env bash
#
# Launch Kodi (Cody) installed via Flatpak
# Prefers user-level Flatpak install, then system, then apt package.
#
# Usage: bash launch-kodi.sh
# or: chmod +x launch-kodi.sh && ./launch-kodi.sh
#

set -euo pipefail

echo "Launching Kodi..."

# Prefer user Flatpak install
if command -v flatpak &> /dev/null && flatpak list --user | grep -q "tv.kodi.Kodi"; then
    exec flatpak run --user tv.kodi.Kodi "$@"
fi

# Then system Flatpak install
if command -v flatpak &> /dev/null && flatpak list | grep -q "tv.kodi.Kodi"; then
    exec flatpak run tv.kodi.Kodi "$@"
fi

# Fallback to system kodi if installed via apt
if command -v kodi &> /dev/null; then
    exec kodi "$@"
fi

echo "Error: Kodi not found."
echo "Install it first with: bash install-kodi.sh"
exit 1
