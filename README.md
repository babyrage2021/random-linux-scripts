# random-linux-scripts

Collection of random bash scripts for setting up things on Linux Mint and other distros.

> **Note:** Scripts are not marked executable in the repo (GitHub API limitation).  
> After cloning, either:
> ```bash
> chmod +x *.sh
> ```
> or run them with `bash script.sh` (no chmod needed).

## Scripts

### install-kodi.sh
Installs **Kodi** (commonly referred to as Cody) on Linux Mint using the recommended Flatpak method (user-level install).

**Usage:**
```bash
bash install-kodi.sh
```

### launch-kodi.sh
Launches Kodi. Prefers the user Flatpak install.

**Usage:**
```bash
bash launch-kodi.sh
```

### setup-kodi-autostart.sh
Sets Kodi to autostart on login in **windowed** mode.

Creates `~/.config/autostart/kodi.desktop` and tries to force windowed mode via Kodi's settings files.

**Usage:**
```bash
bash setup-kodi-autostart.sh
```

True minimized start is not practical with Kodi; windowed is the closest option. You can minimize the window after it starts.

### install-grok-bot.sh
Installs **Grok Bot** (the desktop Electron app) on Linux Mint / Ubuntu via the official Cursor apt repository.

**Usage:**
```bash
bash install-grok-bot.sh
```

### install-proton-drive.sh
Installs the unofficial community Proton Drive Linux client (narrrl/proton-drive-linux) and lets you choose the mount folder.

**Usage:**
```bash
bash install-proton-drive.sh
```

### pull-all-repos.sh + setup-git-pull-all.sh
Finds all Git repos under `$HOME` (or given paths) and pulls them safely (`--ff-only`, skips dirty trees).
`setup-git-pull-all.sh` installs the script into `~/bin` and enables a user systemd service that runs it on login.

**Usage:**
```bash
bash pull-all-repos.sh          # one-off run
bash setup-git-pull-all.sh      # install + enable service
```

Log is written to `~/.local/state/pull-all-repos.log`.

---

More scripts coming soon for various Linux Mint setups.
