#!/usr/bin/env bash
# Toggle touchpads discovered in the current compositor session.
set -euo pipefail
status_file="${XDG_RUNTIME_DIR:?}/touchpad.status"
enabled=false
if [[ -f $status_file && $(<"$status_file") == false ]]; then
  enabled=true
fi
devices=$(hyprctl -j devices | jq -r '.mice[] | select(.name | test("touchpad"; "i")) | .name')
[[ -n $devices ]] || { notify-send 'No touchpad detected'; exit 0; }
commands=''
while IFS= read -r device; do
  # Names become Lua string literals; reject unexpected characters.
  [[ $device =~ ^[a-zA-Z0-9:_.\ -]+$ ]] || exit 1
  commands+="hl.device({ name = \"$device\", enabled = $enabled }); "
done <<< "$devices"
hyprctl eval "$commands"
printf '%s' "$enabled" > "$status_file"
notify-send -u low 'Touchpad' "Enabled: $enabled"
