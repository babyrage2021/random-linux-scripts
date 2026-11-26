#!/usr/bin/env bash
#
# Install Grok Bot (desktop Electron app) on Linux Mint / Ubuntu
# Uses the official Cursor apt repository so it stays up to date.
#
# Usage: bash install-grok-bot.sh
# or: chmod +x install-grok-bot.sh && ./install-grok-bot.sh
#

set -euo pipefail

echo "=== Grok Bot Installer for Linux Mint ==="
echo

if [[ $EUID -eq 0 ]]; then
   echo "Please do not run this script as root. It will ask for sudo when needed."
   exit 1
fi

echo "[1/4] Installing prerequisites..."
sudo apt update
sudo apt install -y curl gnupg ca-certificates

echo "[2/4] Adding Grok Bot signing key..."
curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | gpg --dearmor | sudo tee /usr/share/keyrings/grok-bot.gpg > /dev/null

echo "[3/4] Adding apt repository..."
printf 'Types: deb\nURIs: https://downloads.cursor.com/aptrepo\nSuites: grok-bot\nComponents: main\nSigned-By: /usr/share/keyrings/grok-bot.gpg\n' | sudo tee /etc/apt/sources.list.d/grok-bot.sources > /dev/null

echo "[4/4] Installing Grok Bot..."
sudo apt update
sudo apt install -y grok-bot

echo
echo "Done!"
echo "Launch Grok Bot from the application menu or run: grok-bot"
echo "Sign in with your xAI / Cursor account that has Grok Bot access."
