#!/usr/bin/env bash
#
# Set Kodi (Flatpak user install) to autostart on login in windowed mode.
# Creates a desktop entry in ~/.config/autostart/
# Also tries to force windowed mode via guisettings.xml and advancedsettings.xml.
#
# Usage: bash setup-kodi-autostart.sh
#
# Note: True minimized start is not practical with Kodi. Windowed is the closest option.
# You can still minimize it manually after it starts, or use a tool like kdocker if desired.
#

set -euo pipefail

echo "=== Kodi Autostart Setup (Windowed) ==="
echo

# Flatpak user data path
KODI_DATA="${HOME}/.var/app/tv.kodi.Kodi/data"
USERDATA="${KODI_DATA}/userdata"
GUISETTINGS="${USERDATA}/guisettings.xml"
ADVANCED="${USERDATA}/advancedsettings.xml"

mkdir -p "${HOME}/.config/autostart"
mkdir -p "${USERDATA}"

# Create autostart desktop file
echo "[1/3] Creating autostart entry..."
cat > "${HOME}/.config/autostart/kodi.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Kodi
Comment=Launch Kodi in windowed mode on login
Exec=sh -c 'sleep 5; flatpak run --user tv.kodi.Kodi'
Terminal=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

echo "Autostart file created: ~/.config/autostart/kodi.desktop"

# Force windowed mode in guisettings.xml if it exists
echo "[2/3] Configuring windowed mode..."
if [[ -f "${GUISETTINGS}" ]]; then
    # Backup
    cp "${GUISETTINGS}" "${GUISETTINGS}.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true

    # Update or add the screenmode setting
    if grep -q 'videoscreen.screenmode' "${GUISETTINGS}"; then
        sed -i 's|<setting id="videoscreen.screenmode"[^>]*>[^<]*</setting>|<setting id="videoscreen.screenmode">WINDOW</setting>|g' "${GUISETTINGS}"
    else
        # Insert before </settings> if possible
        sed -i 's|</settings>|  <setting id="videoscreen.screenmode">WINDOW</setting>\n</settings>|' "${GUISETTINGS}"
    fi
    echo "Updated guisettings.xml for windowed mode."
else
    echo "guisettings.xml not found yet (Kodi hasn't been launched). Windowed mode will be set after first launch."
    echo "Run this script again after launching Kodi once if needed."
fi

# Create/update advancedsettings.xml to prefer non-fullscreen
echo "[3/3] Writing advancedsettings.xml..."
if [[ -f "${ADVANCED}" ]]; then
    # If it exists, try to ensure fullscreen is false (simple append if not present)
    if ! grep -q '<fullscreen>' "${ADVANCED}"; then
        # Insert before </advancedsettings>
        sed -i 's|</advancedsettings>|  <fullscreen>false</fullscreen>\n</advancedsettings>|' "${ADVANCED}" 2>/dev/null || \
        echo -e "<advancedsettings>\n  <fullscreen>false</fullscreen>\n</advancedsettings>" >> "${ADVANCED}"
    fi
else
    cat > "${ADVANCED}" << 'EOF'
<advancedsettings>
  <fullscreen>false</fullscreen>
</advancedsettings>
EOF
fi

echo
echo "Done!"
echo "Kodi will autostart on next login (with a short delay)."
echo "It should start in windowed mode."
echo
echo "To remove autostart later:"
echo "  rm ~/.config/autostart/kodi.desktop"
echo
echo "You can also manage it in Linux Mint's Startup Applications tool."
