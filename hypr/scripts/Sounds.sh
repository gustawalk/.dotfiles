#!/bin/bash
# This script is used to play system sounds.
# Script is used by Volume.Sh and ScreenShots.sh
theme="freedesktop" # Set the theme for the system sounds.
mute=false          # Set to true to mute the system sounds.

# Mute individual sounds here.
muteScreenshots=false
muteVolume=false

# Exit if the system sounds are muted.
if [[ "$mute" = true ]]; then
    exit 0
fi

# Choose the sound to play.
if [[ "$1" == "--screenshot" ]]; then
    if [[ "$muteScreenshots" = true ]]; then
        exit 0
    fi
    soundoption="screen-capture.*"
elif [[ "$1" == "--volume" ]]; then
    if [[ "$muteVolume" = true ]]; then
        exit 0
    fi
    soundoption="audio-volume-change.*"
elif [[ "$1" == "--error" ]]; then
    if [[ "$muteScreenshots" = true ]]; then
        exit 0
    fi
    soundoption="dialog-error.*"
else
    echo -e "Available sounds: --screenshot, --volume, --error"
    exit 0
fi

# Look in user, checked-in, and system sound themes, in that order.
sound_file=''
for directory in \
    "$HOME/.local/share/sounds/$theme/stereo" \
    "$HOME/.config/hypr/UserSounds/$theme/stereo" \
    "/usr/share/sounds/$theme/stereo" \
    "/run/current-system/sw/share/sounds/$theme/stereo"; do
    if [[ -d "$directory" ]]; then
        sound_file=$(find -L "$directory" -name "$soundoption" -print -quit)
        [[ -z "$sound_file" ]] || break
    fi
done

if [[ -z "$sound_file" ]]; then
    echo 'Error: Sound file not found.' >&2
    exit 1
fi

if command -v pw-play >/dev/null 2>&1; then
    pw-play "$sound_file"
elif command -v paplay >/dev/null 2>&1; then
    paplay "$sound_file"
else
    echo 'Install PipeWire or PulseAudio playback tools.' >&2
    exit 1
fi
