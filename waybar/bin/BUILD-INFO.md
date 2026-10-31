# Local Waybar build

This is Waybar 0.15.0 with the upstream Hyprland Lua workspace-click fix
from commit `e17c0d9f0a73acc370df60ec8c532b1ed2385c73` applied.

Source: https://github.com/Alexays/Waybar (tag `0.15.0`)
Fix: https://github.com/Alexays/Waybar/pull/5013

The active layout remains `hyprland/workspaces#rw`. Startup and the Hyprland
refresh script launch `bin/waybar`; the system package is unchanged.
