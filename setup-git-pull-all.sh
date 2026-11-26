#!/usr/bin/env bash
#
# setup-git-pull-all.sh
# Install pull-all-repos.sh into ~/bin and enable the user systemd service
# so it runs on login.
#
# Usage:
#   bash setup-git-pull-all.sh
#   bash setup-git-pull-all.sh --no-start   # enable but do not start now

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SCRIPT="$SCRIPT_DIR/pull-all-repos.sh"
DEST_BIN="${HOME}/bin"
DEST_SCRIPT="${DEST_BIN}/pull-all-repos.sh"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/git-pull-all.service"
START_NOW=true

for arg in "$@"; do
  case "$arg" in
    --no-start) START_NOW=false ;;
    -h|--help)
      echo "Usage: $0 [--no-start]"
      exit 0
      ;;
  esac
done

if [[ ! -f "$SRC_SCRIPT" ]]; then
  echo "ERROR: pull-all-repos.sh not found next to this script."
  exit 1
fi

echo "==> Creating ${DEST_BIN}"
mkdir -p "$DEST_BIN"
chmod 755 "$DEST_BIN"

echo "==> Installing pull-all-repos.sh to ${DEST_SCRIPT}"
cp -f "$SRC_SCRIPT" "$DEST_SCRIPT"
chmod 755 "$DEST_SCRIPT"

# Ensure ~/bin is on PATH for interactive shells (optional but helpful)
if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
  echo "==> Added ~/bin to PATH in .bashrc"
fi

echo "==> Writing systemd user service"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Pull all Git repositories on login
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${DEST_SCRIPT}
StandardOutput=journal
StandardError=journal
TimeoutStartSec=300

[Install]
WantedBy=default.target
EOF

echo "==> Reloading systemd user units"
systemctl --user daemon-reload

echo "==> Enabling service"
systemctl --user enable git-pull-all.service

if $START_NOW; then
  echo "==> Starting service once now"
  systemctl --user start git-pull-all.service || true
fi

echo
echo "Done."
echo "  Script:  $DEST_SCRIPT"
echo "  Service: $SERVICE_FILE"
echo
echo "It will run on login. Check with:"
echo "  systemctl --user status git-pull-all.service"
echo "  journalctl --user -u git-pull-all.service -e"
echo "  cat ~/.local/state/pull-all-repos.log"
