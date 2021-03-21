#!/bin/sh

#xrandr --output HDMI-1 --mode 1366x768 --pos 0x0 --rotate normal --output eDP-1 --primary --mode 1366x768 --pos 1366x0 --rotate normal
xrandr --output HDMI-1 --off  --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal
