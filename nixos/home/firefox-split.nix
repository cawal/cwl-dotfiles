# Dois Firefox nativos (Pessoal e Trabalho) no mesmo usuário, cada um com sua
# RAIZ DE PERFIL isolada — para poder logar a MESMA conta Mozilla nos dois sem o
# bloqueio "conta já em uso em outro perfil". O truque é o mesmo do snap+deb do
# Ubuntu: perfis em raízes diferentes têm profiles.ini separados, então uma
# instância é cega para a outra e o bloqueio não dispara (confirmado por teste).
# O compartilhamento de senhas/histórico/favoritos acontece via Firefox Sync
# (mesma conta) — eventual, não ao vivo.
#
#   - Pessoal:  perfil normal em ~/.mozilla (o Firefox de sempre, INTOCADO — o
#               wrapper só adiciona --class na hora de abrir; não mexe no HOME
#               nem no perfil).
#   - Trabalho: HOME redirecionado para ~/.local/share/firefox-trabalho, então o
#               perfil vive em ~/.local/share/firefox-trabalho/.mozilla (isolado).
#               XDG_DOWNLOAD_DIR volta a apontar para o ~/Downloads real; tema/ícones
#               vêm de environment.sessionVariables (nível de sessão), então seguem
#               valendo mesmo com o HOME trocado.
#
# Cada instância sobe com um --class próprio (firefox-pessoal / firefox-trabalho)
# para o qtile/taskbar distinguir as janelas e para o roteador identificá-las.
#
# ROTEADOR: o handler padrão de http/https (em cawal.nix) aponta para
# firefox-router.desktop. Ele encaminha a URL para o Firefox USADO MAIS
# RECENTEMENTE — não o em foco: quando um app nativo (Slack etc.) dispara um
# OAuth, é o app que está em foco, então "em foco" quase nunca acertaria. Em vez
# disso, lemos a ordem de empilhamento das janelas do X (_NET_CLIENT_LIST_STACKING,
# de baixo p/ cima) e pegamos o Firefox mais ao topo (= levantado por último).
# Sem Firefox aberto, cai no Pessoal. X11 apenas (qtile mantém o stacking no foco).
#
# Chamamos o `firefox` do PATH da sessão (o pacote do sistema via
# programs.firefox.enable, que traz policies/native messaging). NÃO embutimos
# pkgs.firefox para não criar um Firefox paralelo sem essas integrações.
#
# NOTA (remoting): não usamos --no-remote. Como cada instância tem perfil próprio,
# o remoting do Firefox é escopado por perfil: reinvocar o wrapper com uma URL
# entrega a aba à instância já aberta daquele perfil (é o que o roteador precisa).
{ config, pkgs, lib, ... }:

let
  firefox-pessoal = pkgs.writeShellApplication {
    name = "firefox-pessoal";
    text = ''
      exec firefox --class firefox-pessoal "$@"
    '';
  };

  firefox-trabalho = pkgs.writeShellApplication {
    name = "firefox-trabalho";
    text = ''
      real_home="$HOME"
      export HOME="$real_home/.local/share/firefox-trabalho"
      export XDG_DOWNLOAD_DIR="$real_home/Downloads"
      mkdir -p "$HOME"
      exec firefox --class firefox-trabalho "$@"
    '';
  };

  firefox-router = pkgs.writeShellApplication {
    name = "firefox-router";
    runtimeInputs = [ pkgs.xorg.xprop firefox-pessoal firefox-trabalho ];
    text = ''
      url="''${1:-}"

      # Percorre as janelas do topo p/ a base (stacking invertido) e para na
      # primeira que seja um dos nossos Firefox = o usado mais recentemente.
      pick=""
      while read -r id; do
        [ -n "$id" ] || continue
        cls="$(xprop -id "$id" WM_CLASS 2>/dev/null || true)"
        case "$cls" in
          *firefox-trabalho*) pick=firefox-trabalho; break ;;
          *firefox-pessoal*)  pick=firefox-pessoal;  break ;;
          *[Ff]irefox*)       pick=firefox-pessoal;  break ;;  # Firefox "pelado"
        esac
      done < <(xprop -root _NET_CLIENT_LIST_STACKING 2>/dev/null \
                 | sed 's/.*# //' | tr -d ' ' | tr ',' '\n' | tac)

      [ -n "$pick" ] || pick=firefox-pessoal   # nenhum Firefox aberto
      exec "$pick" "$url"
    '';
  };
in
{
  home.packages = [ firefox-pessoal firefox-trabalho firefox-router ];

  xdg.desktopEntries = {
    firefox-pessoal = {
      name = "Firefox — Pessoal";
      genericName = "Web Browser";
      exec = "${firefox-pessoal}/bin/firefox-pessoal %U";
      icon = "firefox";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      startupNotify = true;
      settings.StartupWMClass = "firefox-pessoal";
    };

    firefox-trabalho = {
      name = "Firefox — Trabalho";
      genericName = "Web Browser";
      exec = "${firefox-trabalho}/bin/firefox-trabalho %U";
      icon = "firefox";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      startupNotify = true;
      settings.StartupWMClass = "firefox-trabalho";
    };

    # Handler padrão de http/https (ver cawal.nix). NoDisplay: não aparece no
    # menu de apps; só recebe URLs e roteia para a instância em foco.
    firefox-router = {
      name = "Firefox (roteador de contexto)";
      exec = "${firefox-router}/bin/firefox-router %u";
      icon = "firefox";
      terminal = false;
      noDisplay = true;
      mimeType = [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    };
  };
}
