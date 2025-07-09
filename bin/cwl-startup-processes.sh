#!/bin/bash
xrdb ~/.Xresources
compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf  &

# numlock starts activated
# numlockx on &

# notification
#killall -q notify-osd;  &
#killall -q dunst;  &
dunst & # -config ~/.config/i3/dunstrc &
nitrogen --restore &
setxkbmap -option caps:escape &

# tray services
dropbox start &
greenclip daemon &

syncthing &
# bluetooth indicator 
blueman-applet &

# networking
nm-applet &

# keyring
keepassxc &
