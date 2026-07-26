#!/bin/sh
# fi (NixOS, híbrido Intel iGPU + NVIDIA PRIME offload).
# O painel interno eDP-1 é nativo 2560x1600 e, sob o driver NVIDIA, só aceita o
# modo nativo: trocar --mode para uma resolução menor dá "Configure crtc failed".
# Por isso usamos --scale (transform na GPU) para obter ~1680x1050 aparente.
# Como o eDP passa a ocupar 1680px de largura, o HDMI é posicionado em 1680x0.
# --fb fixo 3600x1600 (cobre ambos os layouts) evita o RRSetScreenSize BadMatch
# que ocorre quando o driver NVIDIA tenta encolher a tela ao alternar layouts.
xrandr --fb 3600x1600 --output eDP-1 --primary --mode 2560x1600 --scale 0.65625x0.65625 --pos 0x0 --rotate normal \
    --output HDMI-1-0 --mode 1920x1080 --pos 1680x0 --rotate normal \
    --output DP-1 --off \
    --output DP-2 --off \
    --output DP-3 --off \
    --output DP-4 --off
# Escalado p/ 1680x1050 (densidade normal): reseta DPI de fonte para 96, senão
# o 144 do baseline HiDPI empilha com o --scale e as fontes ficam enormes.
printf 'Xft.dpi: 96\n' | xrdb -merge
