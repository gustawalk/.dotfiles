#!/bin/bash

SOUNDS_DIR="$HOME/.config/hypr/UserSounds"

if systemctl --user is-active --quiet gpu-screen-recorder.service; then
    pkill -USR1 -f gpu-screen-recorder
    play -q -v 0.1 "$SOUNDS_DIR/video_game_select.mp3" &
else
    notify-send "GSR is not running"
fi
