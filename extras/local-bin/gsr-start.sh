#!/usr/bin/env bash
set -euo pipefail

# Override these in the service environment for a custom disk or monitor.
output_dir=${GSR_OUTPUT_DIR:-$HOME/Videos/Clips}
mkdir -p -- "$output_dir"
exec gpu-screen-recorder \
-w "${GSR_MONITOR:-DP-1}" \
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
