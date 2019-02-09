#!/bin/sh
xrandr --output LVDS --primary
compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf
