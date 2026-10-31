#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
dry_run=false yes=false optional=false build_ags=false build_waybar=false with_aur=false
usage() {
  cat <<'HELP'
Usage: ./install-prerequisites.sh [options]
Install this rice's Arch Linux dependencies. Does not link configs or enable services.
  --dry-run          Print the plan without changing anything or downloading files
  --yes              Skip this script's confirmation (package tools still prompt)
  --with-aur         Include wallpaper and theme packages, using existing paru/yay
  --with-optional    Include replay recording, video wallpaper and other extras
  --with-legacy-ags  Build AGS v1.9.0 into ~/.local (modern AGS is incompatible)
  --build-waybar     Rebuild the saved Waybar 0.15.0 + Lua workspace fix
  --all              Enable all of the above optional dependency groups/builds
Other operating systems: ./install-portable.sh --dry-run
HELP
}
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --yes) yes=true ;;
    --with-aur) with_aur=true ;;
    --with-optional) optional=true ;;
    --with-legacy-ags) build_ags=true ;;
    --build-waybar) build_waybar=true ;;
    --all) optional=true; build_ags=true; build_waybar=true; with_aur=true ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done
command -v pacman >/dev/null || { echo 'Arch Linux/pacman required. See install-portable.sh for other systems.' >&2; exit 1; }
read_manifest() { sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"; }
mapfile -t official < <(read_manifest "$root/packages/arch.txt" | sort -u)
extra=()
if $with_aur; then mapfile -t extra < <(read_manifest "$root/packages/aur.txt"); fi
if $optional; then mapfile -t more < <(read_manifest "$root/packages/optional.txt"); extra+=("${more[@]}"); fi
# Packages sometimes migrate between the AUR and official repositories.
aur=()
for package in "${extra[@]}"; do
  if pacman -Si "$package" >/dev/null 2>&1; then official+=("$package"); else aur+=("$package"); fi
done
helper=$(command -v paru || command -v yay || true)
print_command() { printf '  '; printf '%q ' "$@"; printf '\n'; }
echo 'Official packages (full system upgrade avoids an Arch partial upgrade):'
print_command sudo pacman -Syu --needed "${official[@]}"
if ((${#aur[@]})); then
  echo 'AUR packages (review package build files when your helper asks):'
  print_command "${helper:-paru-or-yay}" -S --needed "${aur[@]}"
fi
$build_ags && print_command "$root/scripts/build-legacy-ags.sh"
$build_waybar && print_command "$root/scripts/build-waybar.sh"
echo 'GPU/kernel drivers, display-manager changes and service activation are not included.'
if $dry_run; then echo 'Dry run complete; no changes made.'; exit 0; fi
if ((EUID == 0)); then echo 'Run as your normal user; sudo is used for system packages.' >&2; exit 1; fi
if ((${#aur[@]})) && [[ -z $helper ]]; then
  echo 'Install paru or yay first, or omit --with-aur/--all. No packages installed.' >&2
  exit 1
fi
if ! $yes; then
  read -r -p 'Install the listed dependencies? [y/N] ' answer
  case "$answer" in y|Y|yes|YES) ;; *) echo 'Cancelled.'; exit 0 ;; esac
fi
sudo pacman -Syu --needed "${official[@]}"
if ((${#aur[@]})); then "$helper" -S --needed "${aur[@]}"; fi
if command -v rustup >/dev/null && ! rustup show active-toolchain >/dev/null 2>&1; then rustup default stable; fi
if command -v rustup >/dev/null; then rustup component add rustfmt rust-analyzer; fi
if $build_ags; then "$root/scripts/build-legacy-ags.sh"; fi
if $build_waybar; then "$root/scripts/build-waybar.sh"; fi
echo 'Dependencies installed. Run ./restore.sh --dry-run before restoring configs.'
