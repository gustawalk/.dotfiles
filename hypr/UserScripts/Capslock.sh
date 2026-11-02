#!/bin/bash

# Keep the existing Waybar entry point; the watcher needs only one process.
exec python3 -u "${BASH_SOURCE[0]%/*}/Capslock.py"
