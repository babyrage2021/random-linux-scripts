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

### install-grok-bot.sh
Installs **Grok Bot** (the desktop Electron app) on Linux Mint / Ubuntu via the official Cursor apt repository.

**Usage:**
```bash
bash install-grok-bot.sh
```

After install, launch from the menu or with `grok-bot`. Requires an account that includes Grok Bot access.

---

More scripts coming soon for various Linux Mint setups.
