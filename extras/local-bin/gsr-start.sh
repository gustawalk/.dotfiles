#!/usr/bin/env bash
set -euo pipefail

# Override these in the service environment for a custom disk or monitor.
output_dir=${GSR_OUTPUT_DIR:-$HOME/Videos/Clips}
mkdir -p -- "$output_dir"
monitor=${GSR_MONITOR:-}
if [[ -z $monitor ]]; then
  monitor=$(hyprctl -j monitors | jq -er '(map(select(.focused)) + .)[0].name // empty')
fi
exec gpu-screen-recorder \
-w "$monitor" \
-c mp4 \
-f 60 \
-a "default_input|default_output" \
-o "$output_dir" \
-r 30 \
-replay-storage ram \
-restart-replay-on-save yes \
-k "${GSR_CODEC:-h264}" \
-cursor yes \
-encoder gpu
