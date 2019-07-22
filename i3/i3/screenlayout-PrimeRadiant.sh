#!/bin/sh
xrandr --output LVDS --primary --pos 768x0 --mode 1366x768 --rotate normal --output VGA-0 --mode 1366x768 --pos 0x0 --rotate left
compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf
