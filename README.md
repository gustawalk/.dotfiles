# Dotfiles

Working Arch Linux rice snapshot, synchronized on 2026-10-31. Includes Hyprland
Lua, Kitty, Fish, Waybar, Neovim, tmux, Rofi, SwayNC, Wallust, Wlogout, AGS,
Qt theme settings and btop. Six Pokémon banner sprites and tmux-resurrect are
bundled so they do not depend on a previous home directory.

## Reinstall on Arch Linux

After installing Arch, your hardware drivers, networking and Git:

```bash
git clone https://github.com/gustawalk/.dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
./install-prerequisites.sh --all --dry-run
./install-prerequisites.sh --all
./restore.sh --dry-run
./restore.sh
```

`--all` includes AUR packages, optional tools, an AGS v1 source build, and a
rebuild of the custom Waybar. An existing **paru or yay** is required for AUR
packages. Install one first using its upstream instructions. The installer
preflights this before changing packages, shows its complete plan, and asks for
confirmation. Package managers retain their normal review prompts. Do not run
it as root. `--dry-run` does not install, download, build, or change configs.

For just official packages, omit `--all`. Individual options:

```bash
./install-prerequisites.sh --with-aur
./install-prerequisites.sh --with-optional --with-legacy-ags --build-waybar
```

The install performs `pacman -Syu --needed` to avoid a partial upgrade. See
`packages/arch.txt`, `packages/aur.txt`, and `packages/optional.txt` for editable
manifests. Extra packages are checked against the enabled official repositories
before using the AUR, since packages move between repositories over time.
`packages/installed-official.txt` and `installed-foreign.txt` record all explicitly
installed packages from this PC for reference; the installer does **not** blindly
reinstall that larger inventory. GPU drivers and kernels are deliberately not
chosen by the script.

The older shell/editor installer for Debian, Fedora and macOS remains available
as `./install-portable.sh --dry-run`. The complete desktop restore targets Arch.

## Restore and maintain

`restore.sh` reads `packages/config-folders.txt` and links those directories into
`${XDG_CONFIG_HOME:-$HOME/.config}`. Existing configs are moved, not deleted, into
`${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/<timestamp>-<pid>/`.
Already-correct links are skipped. Fish universal variables are preserved locally
and ignored by Git. No services are enabled and no desktop applications restarted.

After restoration, edits under `~/.config` change the repository through symlinks:

```bash
cd "$HOME/.dotfiles"
git status --short
git diff
# Select the intended files, then commit and push them.
git add fish/config.fish hypr/hyprland.lua
git commit -m "chore: update desktop configuration"
git push
```

The initial sync does not publish or commit anything. Commit and push this snapshot
before formatting the PC. Test restore in a disposable account or VM first.

## Machine-specific setup

- This snapshot retains your existing `/home/walk` paths in Lua, scripts and styles.
  A reinstall with the same username works best. For a different username, review
  `rg -n '/home/walk|/mnt/gustavo' hypr fish ags rofi waybar wallust` before login.
- Review `hypr/monitors.conf`, `workspaces.conf`, `UserConfigs/LaptopDisplay.conf`,
  and the NVIDIA environment in Lua and `fish/conf.d/nvidia-hypr.fish` for new
  hardware. These are saved as your current baseline, not universally portable defaults.
- Wallpaper files under `~/Pictures/wallpapers`, the Flat Remix GTK/icon themes,
  and Bibata cursors under `~/.themes` and `~/.icons` are outside `.config`.
  Back up wallpapers separately. The AUR manifest includes the theme packages;
  use `nwg-look` after installation to select Flat-Remix-GTK-White-Dark-Solid,
  Flat-Remix-Blue-Dark and Bibata-Modern-Ice. Locally modified theme assets need
  a separate backup. GTK settings were not copied because they contain local
  bookmarks and external theme links.
- `fish/conf.d/unity-cli.fish` is excluded: it sources a project on `/mnt/gustavo`.
  Re-create it only after restoring that project. Rust initialization remains
  available through `rustup`; the installer adds rustfmt and rust-analyzer.
- Enable the services you use after checking conflicts: NetworkManager, Bluetooth,
  PipeWire/WirePlumber, and a power-profile service. The installer does not enable
  services or change your default shell. Set Fish as your login shell if desired.
- The replay-buffer keybinds expect `gpu-screen-recorder.service` and
  `~/.local/bin/gsr-start.sh`, which are saved under `extras/`. Review monitor,
  codec and output paths, copy the files to the documented locations, then run
  `systemctl --user daemon-reload`. They are not automatically enabled: the saved
  unit documents an existing NVIDIA/FFmpeg mismatch.
- Hyprland starts Fcitx5; select your keyboard/input methods after login.
- `fish/fish_variables`, histories, caches, secrets, credentials, and archived
  backups are excluded. Save passwords/SSH keys separately using encrypted backups.

## Compatibility and validation

The current config uses **Hyprland 0.56.2 Lua APIs**. Rolling updates may require
configuration changes. `hypr/hyprland.conf` and its legacy menus remain available.
AGS modules use the **v1** resource API; installing current AGS alone does not
support them. `scripts/build-legacy-ags.sh` installs upstream v1.9.0 in `~/.local`.
Ensure `~/.local/bin` is present in the graphical session's PATH. Legacy AGS source
builds may need adaptation on future rolling releases.

`waybar/bin/waybar` is the current local x86_64 build (see `waybar/bin/BUILD-INFO.md`).
Rebuild on a fresh installation if its shared-library ABI changes:

```bash
./scripts/build-waybar.sh --dry-run
./scripts/build-waybar.sh
```

The builder uses upstream Waybar 0.15.0 plus the recorded Lua workspace-click fix.
An existing binary is backed up in the dotfiles state directory first.

Neovim plugins install through lazy.nvim on first launch. Run `:Lazy sync`, then
`:checkhealth`; see `nvim/DEPENDENCIES.md` for Mason, formatters and debuggers.

Useful config checks after installing dependencies:

```bash
bash -n install-prerequisites.sh restore.sh scripts/*.sh
fish -n fish/config.fish
Hyprland --verify-config -c "$PWD/hypr/hyprland.lua"
```

Dry runs and isolated restore checks validate the scripts without installing
packages. A complete clean-machine installation and source builds require a fresh
Arch environment and network access; they have not been executed by this sync.
