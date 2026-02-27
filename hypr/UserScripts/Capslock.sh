#!/bin/bash

LOCKFILE="/tmp/waybar_capslock.lock"
path=$(ls -d /sys/class/leds/input*::capslock 2>/dev/null | head -n1)

if [[ -f "$LOCKFILE" ]]; then
    echo '{"text":"❓","tooltip":"Caps Lock not found","class":"off"}'
    rm -f "$LOCKFILE"
    kill "$(cat "$LOCKFILE")" 2>/dev/null
fi

echo "$$" > "$LOCKFILE"
trap "rm -f '$LOCKFILE'" EXIT

while true; do
    if [[ -n "$path" ]]; then
        brightness=$(cat "$path/brightness" 2>/dev/null)

        if [[ "$brightness" == "1" ]]; then
            echo '{"text":"大","tooltip":"Caps Lock ON","class":"on"}'
        else
            echo '{"text":"小","tooltip":"Caps Lock OFF","class":"off"}'
        fi
    else
        echo '{"text":"❓","tooltip":"Caps Lock not found","class":"off"}'
    fi

    sleep 0.3
done
