# random-linux-scripts

Collection of random bash scripts for setting up things on Linux Mint and other distros.

## Scripts

### install-kodi.sh
Installs **Kodi** (commonly referred to as Cody) on Linux Mint using the recommended Flatpak method.

The official Team Kodi PPA is no longer maintained, so Flatpak/Flathub is the preferred way to get the latest version.

**Usage:**
```bash
# Make executable and run
chmod +x install-kodi.sh
./install-kodi.sh

# Or just run with bash
bash install-kodi.sh
```

After installation, launch Kodi from the menu or with:
```bash
flatpak run tv.kodi.Kodi
```

---

More scripts coming soon for various Linux Mint setups.
