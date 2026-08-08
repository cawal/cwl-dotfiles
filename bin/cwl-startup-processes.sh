#!/usr/bin/env bash
# Qtile startup processes
# Log to file for debugging
exec >> ~/qtile-startup.log 2>&1
echo "=== Qtile startup script started at $(date) ==="

# Apply GTK Adwaita-dark theme settings
echo "Applying Adwaita-dark GTK theme..."
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'"

xrdb ~/.Xresources
# compton --backend glx --vsync drm --glx-no-stencil --config ~/.config/i3/compton.conf  &

# Integra a sessão qtile ao systemd --user. Sem isto o graphical-session.target
# nunca é ativado (o qtile não é um DE), e serviços user como o greenclip
# (WantedBy=graphical-session.target) ficam enabled mas não sobem. Importamos o
# ambiente X (senão clientes X como o greenclip não acham o DISPLAY) e iniciamos
# o qtile-session.target (declarado em nixos/common/services.nix), que puxa o
# graphical-session.target como dependência.
echo "Bootstrapping systemd graphical session..."
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
systemctl --user start qtile-session.target

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
