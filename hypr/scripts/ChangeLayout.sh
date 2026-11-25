#!/bin/bash
# for changing Hyprland Layouts (Master or Dwindle) on the fly

notif="$HOME/.config/swaync/images/ja.png"

LAYOUT=$(hyprctl -j getoption general.layout | jq -r '.str')

case $LAYOUT in
"master")
	# Keep directional focus bindings unchanged across layout switches.
	hyprctl eval 'hl.config({ general = { layout = "dwindle" } }); hl.unbind("SUPER + O"); hl.bind("SUPER + O", hl.dsp.layout("togglesplit"))' || exit 1
  notify-send -e -u low -i "$notif" " Dwindle Layout"
	;;
"dwindle")
	hyprctl eval 'hl.config({ general = { layout = "master" } }); hl.unbind("SUPER + O")' || exit 1
  notify-send -e -u low -i "$notif" " Master Layout"
	;;
*) ;;

esac
