# Dotfiles

Personal Arch Linux rice configuration, updated on 2026-11-02. Includes Hyprland
Lua, Kitty, Fish, Waybar, Neovim, Zed, tmux, Rofi, SwayNC, Wallust, Wlogout, AGS,
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

## Ubuntu compatibility (reviewed 2026-11-25)

The full desktop setup is not an Ubuntu installer. `install-prerequisites.sh`
requires pacman; `install-portable.sh` detects Ubuntu as Debian and installs only
shell/editor/language packages. It does not install this desktop or ensure the
editor versions required by these configs. No Ubuntu installation was tested.

- Ubuntu 26.10 packages Hyprland 0.56.2, matching this Lua configuration's
  baseline. Earlier Ubuntu releases need a separately maintained compatible
  Hyprland stack; the legacy `.conf` files are not an equivalent fallback.
  See [Hyprland installation](https://wiki.hypr.land/getting-started/installation/)
  and [Ubuntu's package](https://packages.ubuntu.com/stonking/hyprland).
- `nvim/DEPENDENCIES.md` requires Neovim 0.12+ and tree-sitter-cli 0.26.1+.
  Ubuntu 24.04 ships Neovim 0.9.5; installing the apt package alone is insufficient.
  Verify versions and install compatible upstream builds before restoring Neovim.
  See [Ubuntu 24.04 package](https://packages.ubuntu.com/noble/editors/neovim).
- Rebuild `waybar/bin/waybar` on Ubuntu with the required development libraries;
  the bundled Arch x86_64 binary is not guaranteed to match Ubuntu's ABI or CPU.
  The build script does not install Ubuntu build dependencies. AGS must remain
  v1.9.0; modern AGS is incompatible with these modules.
- Desktop dependencies, themes, fonts, wallpaper tools, Zed, Television and
  optional recording tools require separate Ubuntu installation. Arch/AUR
  package names cannot be passed directly to apt. The Caps Lock helper needs
  Ubuntu's `python3-evdev` and permission to read the relevant input devices.
- Hardware defaults now use automatic monitor placement and driver selection,
  with no connector-specific workspace assignments. The touchpad toggle discovers
  device names; recording and wallpaper selection choose the focused monitor.
  Wallpapers and theme assets still need separate installation.
- `restore.sh` always links every folder in `packages/config-folders.txt`,
  including Hyprland. For shell/editor-only use on Ubuntu/GNOME, back up and
  link only the individual configs whose dependencies you have prepared.

Preview the portable package plan without installing anything:

```bash
./install-portable.sh --os debian --dry-run
```

Before a full desktop restore, install compatible desktop dependencies, adapt
the hardware settings, run `./restore.sh --dry-run`, and validate the Lua config
with the actual Ubuntu Hyprland installation. A clean Ubuntu VM/laptop test is
still required before claiming full compatibility.

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

Commit and push configuration changes before formatting the PC so the remote
repository contains the current setup. Test restore in a disposable account or VM
first. Personal files, credentials and wallpapers need separate backups.

## Machine-specific setup

- User paths resolve from `HOME` at runtime. Hyprland quotes script paths derived
  from Lua's `os.getenv("HOME")`; Zed tasks use quoted `$HOME` expansion. Restore
  works under another username without editing those paths. Waybar selection
  symlinks are relative, so they do not contain the original home directory.
- Displays default to preferred modes, automatic placement and scale 1. Adjust
  scale for HiDPI screens. Workspaces are not pinned to named connectors; GPU
  backends are selected by the installed drivers. The touchpad toggle discovers
  devices dynamically (the name must contain "touchpad"). Its state is session-local;
  set `DOTFILES_TOUCHPAD` to a device name if Lua should reapply saved state on reload.
- Put optional machine-specific Hyprland settings in `hypr/local.lua`, loaded
  last, and shell settings in `fish/conf.d/local.fish`. Both are Git-ignored.
  For example, use `hl.monitor({ output = "your-output", mode = "preferred",
  position = "auto", scale = 1.5 })` in local.lua for a specific HiDPI display.
  These local files need separate backup. Existing live configs on this PC are
  separate copies; updating the repository does not change its current hardware setup.
- Old Fish universal NVIDIA variables from a previous restore persist even after
  removing their definitions. On a migrated install, inspect `set -U` and erase
  obsolete GPU overrides with `set -eU VARIABLE`; new installs do not set them.
- Wallpaper files under `~/Pictures/wallpapers`, the Flat Remix GTK/icon themes,
  and Bibata cursors under `~/.themes` and `~/.icons` are outside `.config`.
  Back up wallpapers separately. The AUR manifest includes the theme packages;
  use `nwg-look` after installation to select Flat-Remix-GTK-White-Dark-Solid,
  Flat-Remix-Blue-Dark and Bibata-Modern-Ice. Locally modified theme assets need
  a separate backup. GTK settings were not copied because they contain local
  bookmarks and external theme links.
- `fish/conf.d/unity-cli.fish` is excluded: it sources a project on an external mount.
  Re-create it only after restoring that project. Rust initialization remains
  available through `rustup`; the installer adds rustfmt and rust-analyzer.
- Enable the services you use after checking conflicts: NetworkManager, Bluetooth,
  PipeWire/WirePlumber, and a power-profile service. The installer does not enable
  services or change your default shell. Set Fish as your login shell if desired.
- The replay-buffer keybinds expect `gpu-screen-recorder.service` and
  `~/.local/bin/gsr-start.sh`, which are saved under `extras/`. Recordings default
  to `$HOME/Videos/Clips` (created automatically). Set `GSR_OUTPUT_DIR` for a custom
  disk, `GSR_MONITOR` for a fixed monitor (default: focused, then first available), or `GSR_CODEC` for
  another codec (default `h264`) in the service environment using
  `systemctl --user edit gpu-screen-recorder.service`. Copy the files to the
  documented locations, then run `systemctl --user daemon-reload`. They are not
  automatically enabled: the saved unit documents an existing NVIDIA/FFmpeg mismatch.
- Hyprland starts Fcitx5; select your keyboard/input methods after login.
- `fish/fish_variables`, histories, caches, secrets, credentials, and archived
  backups are excluded. Save passwords/SSH keys separately using encrypted backups.

### Optional recording setup

Copy the saved launcher and user service without enabling recording:

```bash
install -Dm755 extras/local-bin/gsr-start.sh "$HOME/.local/bin/gsr-start.sh"
install -Dm644 extras/systemd-user/gpu-screen-recorder.service \
  "$HOME/.config/systemd/user/gpu-screen-recorder.service"
systemctl --user daemon-reload
```

Use `systemctl --user edit gpu-screen-recorder.service` to set machine-local
options. For example, substitute your actual disk path and monitor name:

```ini
[Service]
Environment="GSR_OUTPUT_DIR=/path/to/Clips"
Environment="GSR_MONITOR=HDMI-A-1"
Environment="GSR_CODEC=h264"
```

The default path needs no override and follows the current user's `HOME`.
Review the saved NVIDIA/FFmpeg compatibility note before starting the service.

## Zed

`zed/` includes current JSONC settings, Vim keybindings, tasks and the
`bin/television-open` helper. It is included in `restore.sh`; Arch dependencies
include `zed` (the `zeditor` executable) and `television` (`tv`). The helper uses
`tv` from PATH, falling back to the original `~/.local/bin/tv` location.

Zed's settings request the configured theme/icon extensions automatically. The
local `themes/` directory was empty. The previous settings backup, credentials,
application cache and workspace state are not included. Tasks resolve the helper
through a quoted `$HOME/.config/zed/bin/television-open` command.
The Rust check configuration uses Clippy (`rustup component add clippy`).

## Caps Lock indicator

The active bar uses `custom/capslock` via `hypr/UserScripts/Capslock.py` and
`python-evdev`. It blocks on actual Caps Lock LED events and keyboard device
lifecycle changes, then reads the main keyboard state from Hyprland. Ordinary
keypresses are masked out in the kernel. There is no timed polling; one helper
runs per bar and queries `hyprctl` only at startup or on a relevant event.

This avoids a Waybar 0.15.0 native keyboard-state race: bars can sample LED state
on key release before the compositor applies the change, leaving monitors with
opposite indicators. `大` means Caps Lock on, `小` means off. Existing device
access is required; the installer does not change input permissions.

Regression checks: `python hypr/tests/test_capslock.py`.

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
for script in install-prerequisites.sh restore.sh scripts/*.sh; do
  bash -n "$script" || break
done
fish -n fish/config.fish
python tests/test_portability.py
python hypr/tests/test_capslock.py
Hyprland --verify-config -c "$PWD/hypr/hyprland.lua"
```

The portability checks require Python and the `lua` command, both included in the
Arch dependency manifest. They exercise the changed Lua/Zed launchers with a
different home directory, including spaces and apostrophes, and verify recorder
defaults and environment overrides using stub commands. They do not launch the
real applications or start recording.

Dry runs and isolated restore checks validate the scripts without installing
packages. A complete clean-machine installation and source builds require a fresh
Arch environment and network access; they have not been executed by this sync.
