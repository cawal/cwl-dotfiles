# set-wallpaper <desktop|lock|both> <imagem> — define o wallpaper do desktop
# (nitrogen, persistente via --save) e/ou atualiza a imagem do lockscreen
# (betterlockscreen -u, que gera as versões borradas). Chamado pelo yazi
# (keybind/opener) com orphan=true, já que o -u pode demorar. Ver keymap.toml.
#
# Empacotado por writeShellApplication (nixos/home/cawal.nix): shebang e
# `set -euo pipefail` são injetados; NÃO adicionar. O build roda shellcheck.

notify() { notify-send -a wallpaper "$1" "${2:-}" 2>/dev/null || true; }

mode="${1:-both}"
img="${2:-}"
[ -z "$img" ] && { notify "Wallpaper" "Nenhuma imagem informada."; exit 1; }
[ -f "$img" ] || { notify "Wallpaper" "Arquivo não encontrado: $img"; exit 1; }
name="$(basename "$img")"

set_desktop() {
  if nitrogen --set-zoom-fill --save "$img" >/dev/null 2>&1; then
    notify "Wallpaper do desktop" "$name"
  else
    notify "Falha no nitrogen" "$name"
  fi
}

set_lock() {
  notify "Lockscreen" "gerando blur… ($name)"
  if betterlockscreen -u "$img" >/dev/null 2>&1; then
    notify "Lockscreen atualizado" "$name"
  else
    notify "Falha no betterlockscreen" "$name"
  fi
}

case "$mode" in
  desktop) set_desktop ;;
  lock)    set_lock ;;
  both)    set_desktop; set_lock ;;
  *)       notify "Wallpaper" "Modo inválido: $mode"; exit 1 ;;
esac
