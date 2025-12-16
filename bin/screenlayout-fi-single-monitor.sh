#!/bin/sh
xrandr --output eDP-1 --primary --mode 2560x1600 --pos 0x0 --rotate normal \
    --output HDMI-1-0 --off \
    --output DP-1 --off \
    --output DP-2 --off \
    --output DP-3 --off \
    --output DP-4 --off
