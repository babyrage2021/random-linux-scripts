#!/usr/bin/env bash
#
# install-proton-drive.sh
# Install the unofficial Proton Drive Linux client (narrrl/proton-drive-linux)
# on Linux Mint / Debian / Ubuntu 24.04+ and let the user choose the mount folder.
#
# IMPORTANT:
#   - There is NO official Proton Drive desktop client for Linux.
#   - This installs the community client from https://github.com/narrrl/proton-drive-linux
#   - It is not affiliated with or endorsed by Proton AG.
#   - Tested for Linux Mint 22.x (Ubuntu 24.04 base). Older Mint (21.x / Ubuntu 22.04)
#     may not satisfy the glibc / GTK requirements.
#
# Usage:
#   chmod +x install-proton-drive.sh
#   ./install-proton-drive.sh

set -euo pipefail

REPO="narrrl/proton-drive-linux"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/proton-drive-linux"
CONFIG_FILE="$CONFIG_DIR/config.json"
DEFAULT_MOUNT="$HOME/ProtonDrive"

# ---------- helpers ----------
die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Required command '$1' not found. Install it and try again."; }

# ---------- checks ----------
info "Checking environment..."
need_cmd curl
need_cmd sudo
need_cmd apt-get

if [[ "$(uname -m)" != "x86_64" ]]; then
  die "This script currently supports only x86_64 (amd64)."
fi

# Rough check for a recent enough base (Ubuntu 24.04 / Mint 22+)
if command -v lsb_release >/dev/null 2>&1; then
  UBUNTU_VER=$(lsb_release -rs 2>/dev/null || echo "unknown")
  if [[ "$UBUNTU_VER" =~ ^[0-9]+\.[0-9]+$ ]]; then
    # crude numeric compare: require >= 24.04
    major=${UBUNTU_VER%%.*}
    if (( major < 24 )); then
      echo "WARNING: Detected Ubuntu $UBUNTU_VER. The .deb is built for Ubuntu 24.04+."
      echo "         Installation may fail on older systems (e.g. Linux Mint 21.x)."
      read -r -p "Continue anyway? [y/N] " ans
      [[ "${ans,,}" == "y" ]] || exit 0
    fi
  fi
fi

# ---------- download latest .deb ----------
info "Fetching latest release information from GitHub..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

API_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
DEB_URL=$(echo "$API_JSON" | grep -o 'https://[^"]*proton-drive-linux_[^"]*_amd64\.deb' | head -n1)

[[ -n "$DEB_URL" ]] || die "Could not find an amd64 .deb in the latest release."

DEB_FILE="$TMP_DIR/$(basename "$DEB_URL")"
info "Downloading $DEB_URL ..."
curl -fL --progress-bar -o "$DEB_FILE" "$DEB_URL"

# ---------- install ----------
info "Installing package (sudo required)..."
sudo apt-get update -qq
sudo apt-get install -y "./$DEB_FILE" || sudo dpkg -i "$DEB_FILE" && sudo apt-get install -f -y

# ---------- ask for mount folder ----------
echo
echo "Where should Proton Drive be mounted?"
echo "  Default: $DEFAULT_MOUNT"
echo "  (The folder must be empty when the service starts.)"
read -r -p "Enter path (or press Enter for default): " USER_MOUNT

MOUNT_POINT="${USER_MOUNT:-$DEFAULT_MOUNT}"
# Expand ~ if present
MOUNT_POINT="${MOUNT_POINT/#\~/$HOME}"
MOUNT_POINT=$(realpath -m "$MOUNT_POINT" 2>/dev/null || echo "$MOUNT_POINT")

info "Mount point will be: $MOUNT_POINT"

# Create directory (empty is fine; service refuses to mount over existing files)
if [[ ! -d "$MOUNT_POINT" ]]; then
  mkdir -p "$MOUNT_POINT"
  info "Created directory $MOUNT_POINT"
else
  if [[ -n "$(ls -A "$MOUNT_POINT" 2>/dev/null || true)" ]]; then
    echo "WARNING: $MOUNT_POINT is not empty."
    echo "         The Proton Drive service will refuse to mount over existing files."
    echo "         Please empty it or choose another path before starting the client."
  fi
fi

# ---------- write / update config ----------
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"

if [[ -f "$CONFIG_FILE" ]]; then
  # Update existing mountpoint with a simple sed (jq preferred if available)
  if command -v jq >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq --arg mp "$MOUNT_POINT" '.mountpoint = $mp' "$CONFIG_FILE" > "$tmp"
    mv "$tmp" "$CONFIG_FILE"
  else
    # crude fallback: if the key exists replace it, otherwise append
    if grep -q '"mountpoint"' "$CONFIG_FILE"; then
      sed -i "s|\"mountpoint\"[[:space:]]*:[[:space:]]*\"[^\"]*\"|\"mountpoint\": \"$MOUNT_POINT\"|" "$CONFIG_FILE"
    else
      # insert before the closing brace
      sed -i '$s/}/,\n  "mountpoint": "'"$MOUNT_POINT"'"\n}/' "$CONFIG_FILE"
    fi
  fi
  info "Updated mountpoint in $CONFIG_FILE"
else
  cat > "$CONFIG_FILE" <<EOF
{
  "mountpoint": "$MOUNT_POINT"
}
EOF
  chmod 600 "$CONFIG_FILE"
  info "Created $CONFIG_FILE with mountpoint"
fi

# ---------- done ----------
echo
info "Installation finished."
echo
echo "Next steps:"
echo "  1. Open 'Proton Drive' from your application menu (or run: pdfs-app)"
echo "  2. Sign in with your Proton account (2FA supported)."
echo "  3. The service will mount your Drive at:"
echo "       $MOUNT_POINT"
echo
echo "Notes:"
echo "  - This is an unofficial community client, not made by Proton."
echo "  - Session is stored in your system keyring (GNOME Keyring / KWallet)."
echo "  - To change the folder later: Preferences → General → Location"
echo "  - Documentation: https://github.com/narrrl/proton-drive-linux"
echo "  - To update later, re-run this script or download a newer .deb from the releases page."
echo
info "Done."
