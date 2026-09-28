#!/bin/sh

if systemctl --user is-active --quiet gpu-screen-recorder.service; then
    systemctl --user disable --now gpu-screen-recorder.service
    systemctl --user stop gpu-screen-recorder.service
else
    systemctl --user enable gpu-screen-recorder.service
    systemctl --user start gpu-screen-recorder.service
fi
