#!/usr/bin/env bash
#
# setup-spotify-minimized.sh
# Set up Spotify to start minimized on login.
# The in-app "start minimized" setting is often ignored by the autostart entry.
# This creates a small wrapper and an autostart desktop file that forces minimize.
#
# Usage:
#   bash setup-spotify-minimized.sh

set -euo pipefail

AUTOSTART_DIR="${HOME}/.config/autostart"
WRAPPER="${HOME}/bin/spotify-minimized"
DESKTOP="${AUTOSTART_DIR}/spotify-minimized.desktop"

echo "==> Looking for Spotify..."
SPOTIFY_CMD=""
if command -v spotify >/dev/null 2>&1; then
  SPOTIFY_CMD="spotify"
elif command -v flatpak >/dev/null 2>&1 && flatpak list --app 2>/dev/null | grep -qi spotify; then
  SPOTIFY_CMD="flatpak run com.spotify.Client"
elif command -v snap >/dev/null 2>&1 && snap list 2>/dev/null | grep -qi spotify; then
  SPOTIFY_CMD="snap run spotify"
else
  echo "ERROR: Spotify not found (tried native, flatpak, snap)."
  exit 1
fi
echo "    Found: $SPOTIFY_CMD"

# xdotool is the most reliable way to minimize after launch
if ! command -v xdotool >/dev/null 2>&1; then
  echo "==> Installing xdotool (needed to minimize the window)..."
  sudo apt-get update -qq
  sudo apt-get install -y xdotool
fi

mkdir -p "${HOME}/bin" "$AUTOSTART_DIR"

echo "==> Writing wrapper: $WRAPPER"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
# Start Spotify and force it minimized.
# Works around the in-app "start minimized" setting being ignored on autostart.

$SPOTIFY_CMD "\$@" &
PID=\$!

# Wait for the window to appear, then minimize it
for i in {1..30}; do
  if xdotool search --class spotify >/dev/null 2>&1 || \\
     xdotool search --class Spotify >/dev/null 2>&1; then
    sleep 1
    xdotool search --class spotify windowminimize %@ 2>/dev/null || \\
    xdotool search --class Spotify windowminimize %@ 2>/dev/null || true
    break
  fi
  sleep 0.5
done

wait \$PID
EOF
chmod 755 "$WRAPPER"

echo "==> Writing autostart entry: $DESKTOP"
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=Spotify (minimized)
Comment=Start Spotify minimized on login
Exec=${WRAPPER}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
EOF

echo
echo "Done."
echo "  Wrapper:   $WRAPPER"
echo "  Autostart: $DESKTOP"
echo
echo "Spotify will start minimized on next login."
echo "If it still opens maximized, log out/in or reboot once."
echo
echo "To remove:"
echo "  rm -f $DESKTOP $WRAPPER"
