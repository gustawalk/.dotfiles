#!/usr/bin/env bash
set -euo pipefail
# Source matches resource:///com/github/Aylur/ags imports in this configuration.
prefix=${AGS_PREFIX:-$HOME/.local}
if [[ ${1:-} == --dry-run ]]; then
  echo "Clone Aylur/ags v1.9.0; meson setup --prefix=$prefix; compile and install as the current user."
  exit 0
fi
[[ $# == 0 ]] || { echo 'Usage: build-legacy-ags.sh [--dry-run]' >&2; exit 2; }
((EUID != 0)) || { echo 'Run as your normal user.' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 --branch v1.9.0 --recurse-submodules https://github.com/Aylur/ags.git "$work/ags"
# Install the TypeScript/GIR dependencies used by the v1 source tree.
if [[ -f $work/ags/package-lock.json ]]; then
  (cd "$work/ags" && npm ci --ignore-scripts --no-audit --no-fund)
else
  (cd "$work/ags" && npm install --ignore-scripts --no-audit --no-fund)
fi
export PATH="$work/ags/node_modules/.bin:$PATH"
meson setup "$work/ags/build" "$work/ags" --prefix="$prefix" --libdir=lib
meson compile -C "$work/ags/build"
meson install -C "$work/ags/build"
echo "AGS v1 installed in $prefix; ensure $prefix/bin is on your login PATH."
