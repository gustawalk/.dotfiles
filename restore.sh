#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config=${XDG_CONFIG_HOME:-$HOME/.config}
state=${XDG_STATE_HOME:-$HOME/.local/state}
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --help|-h) echo 'Usage: ./restore.sh [--dry-run]'; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done
backup="$state/dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
# Check the complete selection before touching existing configs.
mapfile -t folders < "$root/packages/config-folders.txt"
for name in "${folders[@]}"; do
  [[ $name =~ ^[a-zA-Z0-9_-]+$ && -d $root/$name ]] || { echo "Invalid/missing config: $name" >&2; exit 1; }
  [[ $(realpath -m -- "$config/$name") != "$root/$name" || -L $config/$name ]] || {
    echo "Source and destination overlap: $name" >&2; exit 1;
  }
done
for name in "${folders[@]}"; do
  source="$root/$name" target="$config/$name"
  if [[ -L $target && $(readlink -f -- "$target") == "$source" ]]; then
    echo "Already linked: $name"
    continue
  fi
  if [[ -e $target || -L $target ]]; then
    printf 'Back up %s -> %s\n' "$target" "$backup/$name"
    if ! $dry_run; then mkdir -p -- "$backup"; mv -- "$target" "$backup/$name"; fi
  fi
  printf 'Link %s -> %s\n' "$target" "$source"
  if ! $dry_run; then
    mkdir -p -- "$config"
    ln -s -- "$source" "$target"
    # Fish universal settings stay local and ignored by Git.
    if [[ $name == fish && -f $backup/fish/fish_variables && ! -e $source/fish_variables ]]; then
      cp -p -- "$backup/fish/fish_variables" "$source/fish_variables"
    fi
  fi
done
if $dry_run; then echo 'Dry run complete; no configs changed.'; else echo "Restore complete. Existing configs, if any, are in $backup"; fi
