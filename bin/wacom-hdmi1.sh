#!/bin/sh
# Sets wacom to HDMI-1 display
# xsetwacom --get "Wacom Intuos BT S Pen stylus" Area
# 0 0 15200 9500
#
# 1920 15200
# 1080 X
#
# x = (15200 / 1920) * 1080
# x = 8550


xsetwacom --set "Wacom Intuos BT S Pen stylus" MapToOutput HDMI-1
xsetwacom --get "Wacom Intuos BT S Pen stylus" Area 0 0 15200 8550


