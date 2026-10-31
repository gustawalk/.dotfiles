#!/usr/bin/env bash
set -euo pipefail

# No argument copies a frozen screen region. The older named modes are kept
# for the laptop shortcuts in UserConfigs/Laptops.conf.
mode=${1:---copy-area}
screenshot_cursor_flag="$HOME/.config/hypr/flags/.screenshot_cursor_flag"
freeze=''
area=''
restore_cursor=''
picker_events_pid=''
temporary_screenshot=''
set_cursor_invisible() {
  local value=$1 reply
  reply=$(hyprctl eval "hl.config({ cursor = { invisible = $value } })" 2>&1) || true
  if [[ $reply == ok ]]; then
    return 0
  fi

  # A session started with hyprland.conf still uses the legacy config manager.
  reply=$(hyprctl keyword cursor:invisible "$value" 2>&1) || true
  if [[ $reply == ok ]]; then
    return 0
  fi
  printf 'Could not change cursor visibility: %s\n' "$reply" >&2
  return 1
}
show_cursor() {
  if [[ -n $restore_cursor ]]; then
    set_cursor_invisible "$restore_cursor" >/dev/null 2>&1 || true
    restore_cursor=''
  fi
}
hide_cursor_for_capture() {
  local current_cursor cursor_hidden
  current_cursor=$(hyprctl -j getoption cursor:invisible | jq -r 'if .int == 1 or .bool == true then "true" else "false" end')
  restore_cursor=$current_cursor
  set_cursor_invisible true

  cursor_hidden=false
  for _ in {1..10}; do
    if [[ $(hyprctl -j getoption cursor:invisible | jq -r 'if .int == 1 or .bool == true then "true" else "false" end') == true ]]; then
      cursor_hidden=true
      break
    fi
    sleep 0.03
  done
  if [[ $cursor_hidden != true ]]; then
    echo 'Could not hide the cursor before capturing the screen' >&2
    return 1
  fi

  # Let the compositor finish drawing without the pointer before taking a
  # screencopy; the copy also waits for a completed frame.
  sleep 0.1
  grim -t ppm - >/dev/null
}
cleanup() {
  show_cursor
  if [[ -n $temporary_screenshot ]]; then
    rm -f -- "$temporary_screenshot"
  fi
  if [[ -n $picker_events_pid ]]; then
    kill "$picker_events_pid" 2>/dev/null || true
    wait "$picker_events_pid" 2>/dev/null || true
  fi
  if [[ -n $freeze ]]; then
    kill "$freeze" 2>/dev/null || true
    wait "$freeze" 2>/dev/null || true
  fi
}
trap cleanup EXIT

finish_capture() {
  show_cursor
  if [[ -n $freeze ]]; then
    kill "$freeze" 2>/dev/null || true
    wait "$freeze" 2>/dev/null || true
    freeze=''
  fi
}

pictures_dir="$HOME/Pictures"
if command -v xdg-user-dir >/dev/null 2>&1; then
  pictures_dir=$(xdg-user-dir PICTURES)
fi
screenshot_dir="$pictures_dir/Screenshots"
filename="Screenshot_$(date +%Y-%m-%d_%H-%M-%S)_$$.png"

select_area() {
  if command -v hyprpicker >/dev/null 2>&1; then
    local monitor_count event_ready picker_ready
    local picker_args=(-r -z)
    if [[ -f $screenshot_cursor_flag && $(<"$screenshot_cursor_flag") == 1 ]]; then
      # Hyprpicker's -c flag includes the pointer in its frozen frame.
      picker_args+=(-c)
    else
      # Hide the compositor cursor only while hyprpicker captures its frozen
      # frame; restore it before slurp so area selection still has a pointer.
      hide_cursor_for_capture
    fi
    monitor_count=$(hyprctl -j monitors | jq 'length')

    # Subscribe before starting hyprpicker. Hyprland emits openlayer only when
    # a layer maps, which happens after hyprpicker attaches its captured frame.
    coproc PICKER_EVENTS {
      python3 -u -c '
import os
import socket
import sys

path = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr",
                    os.environ["HYPRLAND_INSTANCE_SIGNATURE"], ".socket2.sock")
with socket.socket(socket.AF_UNIX) as connection:
    connection.connect(path)
    print("ready", flush=True)
    mapped = 0
    for line in connection.makefile():
        if line.rstrip("\n") == "openlayer>>hyprpicker":
            mapped += 1
            if mapped >= int(sys.argv[1]):
                print("mapped", flush=True)
                break
' "$monitor_count"
    }
    picker_events_pid=$PICKER_EVENTS_PID
    if ! read -r -t 2 event_ready <&"${PICKER_EVENTS[0]}" || [[ $event_ready != ready ]]; then
      echo 'Could not subscribe to Hyprland layer events' >&2
      return 1
    fi
    hyprpicker "${picker_args[@]}" &
    freeze=$!
    if ! read -r -t 10 picker_ready <&"${PICKER_EVENTS[0]}" || [[ $picker_ready != mapped ]]; then
      echo 'Hyprpicker did not finish freezing the screen' >&2
      return 1
    fi
    wait "$picker_events_pid" 2>/dev/null || true
    picker_events_pid=''
    show_cursor
  fi
  area=$(slurp -b 000000a0)
  # The live pointer is needed for slurp, but must be hidden again before grim
  # records the selected region of the frozen preview.
  if [[ ! -f $screenshot_cursor_flag || $(<"$screenshot_cursor_flag") != 1 ]]; then
    hide_cursor_for_capture
  fi
}

save_and_copy() {
  mkdir -p "$screenshot_dir"
  grim "$@" "$screenshot_dir/$filename"
  finish_capture
  wl-copy < "$screenshot_dir/$filename"
  printf 'Saved %s\n' "$screenshot_dir/$filename"
}

capture_area_to_temp() {
  temporary_screenshot=$(mktemp --suffix=.png)
  grim -g "$area" "$temporary_screenshot"
  finish_capture
}

case "$mode" in
  --copy-area)
    select_area
    capture_area_to_temp
    wl-copy < "$temporary_screenshot"
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
    capture_area_to_temp
    swappy -f "$temporary_screenshot"
    ;;
  --help|-h)
    echo 'Usage: ScreenShot.sh [--copy-area|--area|--now|--in5|--in10|--active|--win|--swappy]'
    ;;
  *) echo "Unknown screenshot mode: $mode" >&2; exit 2 ;;
esac
