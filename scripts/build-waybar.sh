#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
fix=e17c0d9f0a73acc370df60ec8c532b1ed2385c73
if [[ ${1:-} == --dry-run ]]; then
  echo "Build Waybar 0.15.0 with fix $fix; copy to $root/waybar/bin/waybar (back up existing binary)."
  exit 0
fi
[[ $# == 0 ]] || { echo 'Usage: build-waybar.sh [--dry-run]' >&2; exit 2; }
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 --branch 0.15.0 https://github.com/Alexays/Waybar.git "$work/waybar"
git -C "$work/waybar" fetch --depth 1 origin "$fix"
git -C "$work/waybar" cherry-pick --no-commit FETCH_HEAD
meson setup "$work/waybar/build" "$work/waybar" --buildtype=release -Dtests=disabled -Dman-pages=disabled
meson compile -C "$work/waybar/build"
if [[ -f $root/waybar/bin/waybar ]]; then
  backup=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/waybar-$(date +%Y%m%d-%H%M%S)-$$
  mkdir -p -- "$(dirname -- "$backup")"
  cp -p -- "$root/waybar/bin/waybar" "$backup"
fi
install -Dm755 "$work/waybar/build/waybar" "$root/waybar/bin/waybar"
