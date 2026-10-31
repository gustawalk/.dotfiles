#!/bin/bash
gpu-screen-recorder \
-w DP-1 \
-c mp4 \
-f 60 \
-a "default_input|default_output" \
-o "/mnt/gustavo/clips/" \
-r 30 \
-replay-storage ram \
-restart-replay-on-save yes \
-k h264 \
-cursor yes \
-encoder gpu
