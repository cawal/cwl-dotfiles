#!/bin/sh
pkill compton
xrandr --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal --output HDMI-1  --mode 1920x1080 --pos 1366x0 --rotate normal
nitrogen --restore
compton
