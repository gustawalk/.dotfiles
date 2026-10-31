#!/bin/bash

# Waybar owns this streaming process; each bar can monitor independently.
path=""
for led in /sys/class/leds/input*::capslock; do
    if [[ -r "$led/brightness" ]]; then
        path="$led/brightness"
        break
    fi
done

previous=""
while true; do
    brightness="missing"
    if [[ -n "$path" ]]; then
        IFS= read -r brightness < "$path" || brightness="missing"
    fi

    if [[ "$brightness" != "$previous" ]]; then
        case "$brightness" in
            1) echo '{"text":"大","tooltip":"Caps Lock ON","class":"on"}' ;;
            0) echo '{"text":"小","tooltip":"Caps Lock OFF","class":"off"}' ;;
            *) echo '{"text":"❓","tooltip":"Caps Lock not found","class":"off"}' ;;
        esac
        previous="$brightness"
    fi
    sleep 0.3
done
