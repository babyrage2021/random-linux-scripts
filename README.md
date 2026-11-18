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

The official Team Kodi PPA is no longer maintained, so Flatpak/Flathub is the preferred way to get the latest version.

**Usage:**
```bash
chmod +x install-kodi.sh
./install-kodi.sh
# or
bash install-kodi.sh
```

### launch-kodi.sh
Launches Kodi. Prefers the user Flatpak install, then system Flatpak, then apt package.

**Usage:**
```bash
chmod +x launch-kodi.sh
./launch-kodi.sh
# or
bash launch-kodi.sh
```

---

More scripts coming soon for various Linux Mint setups.
