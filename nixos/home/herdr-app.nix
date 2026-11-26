# App desktop do herdr (herdr-app), lado a lado com a TUI (`herdr`, que vem do
# flake em common/development.nix).
#
# Fica FORA do Nix de propósito: instalado pelo script oficial em
# ~/.local/share/herdr-app (+ ~/.local/bin/herdr-app e o herdr-core/hc), para
# manter o auto-update do próprio app, que também atualiza o herdr-core.
# Mesmo modelo do skills.nix: a activation só instala se faltar; com o app
# presente, não faz nada e quem cuida das versões é ele.
#
# O binário é pré-compilado e roda via nix-ld; as libs dele (xcb, xkbcommon,
# Vulkan, Wayland, EGL) estão em common/base.nix (programs.nix-ld.libraries).
#
# São dois runtimes diferentes: as sessões do app vivem no herdr-core, as da
# TUI no servidor do `herdr`. Um não enxerga as sessões do outro.
#
# O instalador confere o SHA-256 contra o latest.json do mesmo servidor (sem
# assinatura no Linux). Telemetria vem ligada: desligar em Settings → Privacy.
#
# Config versionada em ../../herdr-app/ (keys.json, settings.json), linkada
# direto em ~/.config/herdr-app/ pela activation (link vivo, como no
# claude.nix). O resto da pasta é do app (mods, layouts, estado) e fica fora.
# NÃO dá para compartilhar com a TUI: formatos e modelos diferentes (o app
# não tem tecla de prefixo e não lê o config.toml). Só o diretório de
# worktrees é o mesmo nos dois, ~/git/worktrees: mude nos dois juntos.
# Atenção: um keys.json editado deixa de receber os atalhos padrão novos das
# atualizações; eles precisam ser acrescentados à mão.
#
# Para remover: apague ~/.local/share/herdr-app, ~/.local/bin/{herdr-app,
# herdr-core,hc} e ~/.local/share/applications/herdr-app.desktop, e tire o
# import em cawal.nix (senão a activation reinstala).
{ lib, pkgs, ... }:

let
  # O instalador precisa de curl, tar/gzip e sha256sum (coreutils).
  binPath = lib.makeBinPath [ pkgs.curl pkgs.gnutar pkgs.gzip pkgs.coreutils pkgs.gnused ];

  repo = "/home/cawal/git/cwl-dotfiles/herdr-app";
  linked = [ "keys.json" "settings.json" ];
in
{
  home.activation.installHerdrApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.local/share/herdr-app/herdr-app" ]; then
      echo "herdr-app: instalando pelo script oficial"
      PATH="${binPath}:$PATH" \
        sh -c 'curl -fsSL https://releases.herdr.dev/app/install.sh | sh' \
        || echo "herdr-app: FALHA na instalação (segue o rebuild)"
    fi
  '';

  # Um arquivo comum no lugar vira <nome>.backup em vez de ser sobrescrito.
  home.activation.herdrAppLinks = lib.hm.dag.entryAfter [ "installHerdrApp" ] (
    lib.concatMapStrings (name: ''
      dest="$HOME/.config/herdr-app/${name}"
      if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "herdr-app: movendo $dest para $dest.backup"
        mv "$dest" "$dest.backup"
      fi
      mkdir -p "$HOME/.config/herdr-app"
      ln -sfn "${repo}/${name}" "$dest"
    '') linked
  );
}
