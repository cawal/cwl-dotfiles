#!/usr/bin/env bash
# Qtile startup processes
# Log to file for debugging
exec >> ~/qtile-startup.log 2>&1
echo "=== Qtile startup script started at $(date) ==="

# Apply GTK dark theme settings
echo "Applying GTK dark theme..."
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'"

xrdb ~/.Xresources
# compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf  &

# numlock starts activated
# numlockx on &

# notification
#killall -q notify-osd;  &
#killall -q dunst;  &
dunst & # -config ~/.config/i3/dunstrc &
nitrogen --restore &

# tray services
echo "Starting tray services..."
# dropbox start &  # Disabled - not using dropbox on NixOS yet
# greenclip daemon &  # Managed by NixOS systemd service

# syncthing &  # Managed by NixOS systemd service
# bluetooth indicator 
echo "Starting blueman-applet..."
blueman-applet &

# networking
echo "Starting nm-applet..."
nm-applet &

# keyring
echo "Starting keepassxc..."
keepassxc &

echo "=== Qtile startup script completed at $(date) ==="
