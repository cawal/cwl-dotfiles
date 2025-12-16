#!/bin/sh
pkill compton
xrandr --output HDMI-1 --off  --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal
compton
