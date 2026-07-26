#!/bin/sh
# fi: layout single (só painel interno). --fb fixo 3600x1600 igual ao double para
# nunca precisar encolher o framebuffer (o driver NVIDIA falha ao reduzir a tela,
# dando RRSetScreenSize BadMatch). --scale 1x1 reseta o transform caso venha do
# layout double (que usa --scale 0.65625).
xrandr --fb 3600x1600 --output eDP-1 --primary --mode 2560x1600 --scale 1x1 --pos 0x0 --rotate normal \
    --output HDMI-1-0 --off \
    --output DP-1 --off \
    --output DP-2 --off \
    --output DP-3 --off \
    --output DP-4 --off
# Painel nativo 2560x1600 (HiDPI): fixa DPI de fonte em 144 (~1.5x).
printf 'Xft.dpi: 144\n' | xrdb -merge
