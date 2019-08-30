#!/bin/sh
xrandr --output eDP-1 --primary --mode 1366x768 --pos 768x0 --rotate normal --output DP-1 --off --output HDMI-1 --mode 1366x768 --pos 0x0 --rotate left
compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf
