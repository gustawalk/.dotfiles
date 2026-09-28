#!/usr/bin/env bash
set -euo pipefail

# No argument copies a frozen screen region. The older named modes are kept
# for the laptop shortcuts in UserConfigs/Laptops.conf.
mode=${1:---copy-area}
freeze=''
area=''
cleanup() {
  if [[ -n $freeze ]]; then
    kill "$freeze" 2>/dev/null || true
    wait "$freeze" 2>/dev/null || true
  fi
}
trap cleanup EXIT

pictures_dir="$HOME/Pictures"
if command -v xdg-user-dir >/dev/null 2>&1; then
  pictures_dir=$(xdg-user-dir PICTURES)
fi
screenshot_dir="$pictures_dir/Screenshots"
filename="Screenshot_$(date +%Y-%m-%d_%H-%M-%S)_$$.png"

select_area() {
  if command -v hyprpicker >/dev/null 2>&1; then
    hyprpicker -r -z &
    freeze=$!
    sleep 0.2
  fi
  area=$(slurp -b 000000a0)
}

save_and_copy() {
  mkdir -p "$screenshot_dir"
  grim "$@" "$screenshot_dir/$filename"
  wl-copy < "$screenshot_dir/$filename"
  printf 'Saved %s\n' "$screenshot_dir/$filename"
}

case "$mode" in
  --copy-area)
    select_area
    grim -g "$area" - | wl-copy
    ;;
  --area)
    select_area
    save_and_copy -g "$area"
    ;;
  --now) save_and_copy ;;
  --in5) sleep 5; save_and_copy ;;
  --in10) sleep 10; save_and_copy ;;
  --win|--active)
    geometry=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    save_and_copy -g "$geometry"
    ;;
  --swappy)
    select_area
    grim -g "$area" - | swappy -f -
    ;;
  --help|-h)
    echo 'Usage: ScreenShot.sh [--copy-area|--area|--now|--in5|--in10|--active|--win|--swappy]'
    ;;
  *) echo "Unknown screenshot mode: $mode" >&2; exit 2 ;;
esac
