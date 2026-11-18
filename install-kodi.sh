#!/usr/bin/env bash
#
# Install Kodi (often called Cody) on Linux Mint via Flatpak
# Flatpak is the current recommended method as the Team Kodi PPA is no longer maintained.
# Uses user-level install to avoid "Deploy not allowed for user" errors.
#
# Usage: bash install-kodi.sh
# or: chmod +x install-kodi.sh && ./install-kodi.sh
#

set -euo pipefail

echo "=== Kodi (Cody) Installer for Linux Mint ==="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Please do not run this script as root. It will ask for sudo when needed."
   exit 1
fi

# Update package lists
echo "[1/5] Updating package lists..."
sudo apt update

# Install Flatpak if not present
echo "[2/5] Checking for Flatpak..."
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found. Installing..."
    sudo apt install -y flatpak
else
    echo "Flatpak is already installed."
fi

# Add Flathub remote for the user if not already added
echo "[3/5] Setting up Flathub (user)..."
if ! flatpak remote-list --user | grep -q flathub; then
    echo "Adding Flathub repository for user..."
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "Flathub is already configured for user."
fi

# Install Kodi as user
echo "[4/5] Installing Kodi from Flathub (user)..."
flatpak install --user -y flathub tv.kodi.Kodi

echo "[5/5] Setup complete!"
echo
echo "Kodi has been installed via Flatpak (user)."
echo "You can launch it from the application menu (search for Kodi)"
echo "or from the terminal with:"
echo "  flatpak run --user tv.kodi.Kodi"
echo
echo "First launch will create your ~/.var/app/tv.kodi.Kodi/ data directory."
echo "For HTPC setups, consider enabling hardware acceleration in Settings > Player > Videos."
echo
echo "Done!"
