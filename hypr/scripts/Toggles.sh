#!/bin/bash

FLAGS_DIR="$HOME/.config/hypr/flags"
ICONS_DIR="$HOME/.config/swaync/icons"
SOUNDS_DIR="$HOME/.config/hypr/UserSounds"

mkdir -p "$FLAGS_DIR"

declare -A FLAGS_NAMES=(
    [".sddm_refresh_flag"]="SDDM Theme Refresh"
    [".theme_refresh_flag"]="Auto Theme Refresh"
    [".second_monitor_change_theme_flag"]="Second Monitor Change Theme"
    [".same_wallpapers_flag"]="Same Wallpapers On Monitors"
    [".replay_buffer_flag"]="Replay Buffer"
)

ORDER=(
    ".theme_refresh_flag"
    ".same_wallpapers_flag"
    ".replay_buffer_flag"
    ".sddm_refresh_flag"
    ".second_monitor_change_theme_flag"
)

options=""
for flag_file in $(printf "%s\n" "${ORDER[@]}"); do
    if [[ -f "$FLAGS_DIR/$flag_file" && $(cat "$FLAGS_DIR/$flag_file") -eq 1 ]]; then
        status="ON"
        icon="$ICONS_DIR/toggle_on.png"
    else
        status="OFF"
        icon="$ICONS_DIR/toggle_off.png"
    fi

    if [ -n "$options" ]; then
        options+="\n"
    fi
    options+="${FLAGS_NAMES[$flag_file]}   [$status]\x00icon\x1f${icon}"
done

chosen=$(echo -e "$options" | sed '/^&/d' | rofi -dmenu -p "Toggles" -show-icons -theme-str '
  window {
      width: 50%;
  }
  listview {
    columns: 1;
    lines: 4;
    spacing: 10px;
  }
  element {
    padding: 12px;
    orientation: horizontal;
    spacing: 15px;
  }
  element-icon {
    size: 128px;
  }
  element-text {
    font: "JetBrainsMono Nerd Font 16";
    horizontal-align: 0;
  }
  entry {
      placeholder: "Search Toggle:";
  }
')

selected_name=$(echo "$chosen" | sed -E 's/\s+\[.*\]$//')

for flag_file in "${!FLAGS_NAMES[@]}"; do
    if [[ "$selected_name" == "${FLAGS_NAMES[$flag_file]}" ]]; then
        if [[ -f "$FLAGS_DIR/$flag_file" && $(cat "$FLAGS_DIR/$flag_file") -eq 1 ]]; then
            echo 0 > "$FLAGS_DIR/$flag_file"
            play -q -v 0.1 "$SOUNDS_DIR/menu_sound_effect.mp3" &
        else
            echo 1 > "$FLAGS_DIR/$flag_file"
            play -q -v 0.1 "$SOUNDS_DIR/video_game_select.mp3" &
        fi
        if [[ "$selected_name" == "Replay Buffer" ]]; then
            if systemctl --user is-active --quiet gpu-screen-recorder.service; then
                systemctl --user stop gpu-screen-recorder.service
            else
                systemctl --user start --now gpu-screen-recorder.service
            fi
        fi
        break
    fi
done

