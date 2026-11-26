#!/usr/bin/env bash
#
# setup-disable-dpms.sh
# Disable screen power management (DPMS) on login so TigerVNC
# continues to accept mouse clicks when the physical TV/monitor is off.
#
# Usage:
#   bash setup-disable-dpms.sh
#   bash setup-disable-dpms.sh --remove   # undo

set -euo pipefail

AUTOSTART_DIR="${HOME}/.config/autostart"
DESKTOP="${AUTOSTART_DIR}/disable-dpms.desktop"
REMOVE=false

for arg in "$@"; do
  case "$arg" in
    --remove) REMOVE=true ;;
    -h|--help)
      echo "Usage: $0 [--remove]"
      exit 0
      ;;
  esac
done

if $REMOVE; then
  if [[ -f "$DESKTOP" ]]; then
    rm -f "$DESKTOP"
    echo "Removed $DESKTOP"
  else
    echo "Nothing to remove."
  fi
  exit 0
fi

mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP" << 'EOF'
[Desktop Entry]
Type=Application
Name=Disable DPMS
Comment=Keep display awake so TigerVNC mouse works when TV is off
Exec=sh -c "sleep 5; xset -dpms; xset s off; xset s noblank"
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
StartupNotify=false
EOF

chmod 644 "$DESKTOP"

# Apply immediately for the current session
if command -v xset >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  xset -dpms
  xset s off
  xset s noblank
  echo "Applied now to current session."
else
  echo "Will apply on next login (no DISPLAY or xset missing)."
fi

echo
echo "Done."
echo "  Autostart: $DESKTOP"
echo
echo "DPMS is disabled. Mouse clicks should keep working in TigerVNC"
echo "even when the TV is off."
echo
echo "To undo: bash $0 --remove"
