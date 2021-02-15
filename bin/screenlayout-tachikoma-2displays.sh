#!/bin/sh

xrandr --dpi 110
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal 
xrandr --output HDMI-1 --mode 1366x768 --pos 1920x0 --rotate normal --scale 1.1x1.1

xrandr --output DP-1 --off --output HDMI-2 --off
