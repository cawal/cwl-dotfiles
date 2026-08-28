# ESBOÇO / PILOTO — configuração home-manager do usuário cawal.
#
# Ativado junto com `nixos-rebuild switch` (via módulo no flake.nix).
# É a LISTA ÚNICA do que o HM gerencia no seu $HOME — diferente do stow,
# você não precisa lembrar o que foi "linkado": está tudo declarado aqui.
#
# Dois padrões de gerência convivem abaixo:
#   1. programs.<app>  → config declarativa + integrações (ex.: plugins do nixpkgs)
#   2. mkOutOfStoreSymlink → symlink VIVO para o repo (igual stow, edita sem rebuild)

{ config, pkgs, ... }:

let
  # Dispatcher chamado pelos atalhos do yazi sob o prefixo `o` (move, open,
  # rename, delete, prop, backlinks, links, outline, search, create). Opera
  # num vault do Obsidian via CLI, corrigindo wikilinks nas operações de
  # arquivo. Precisa de nome estável no PATH porque o keymap.toml é estático.
  obsidian-yazi = pkgs.writeShellApplication {
    name = "obsidian-yazi";
    runtimeInputs = [
      pkgs.libnotify # notify-send (feedback via toast)
    ];
    text = builtins.readFile ./yazi/obsidian-yazi.sh;
  };

  # Define wallpaper do desktop (nitrogen) e/ou do lockscreen (betterlockscreen).
  # Chamado pelos atalhos de wallpaper do yazi. nitrogen/betterlockscreen vêm do
  # system profile (ambient PATH), então só o notify-send entra como runtimeInput.
  set-wallpaper = pkgs.writeShellApplication {
    name = "set-wallpaper";
    runtimeInputs = [ pkgs.libnotify ];
    text = builtins.readFile ./yazi/set-wallpaper.sh;
  };
in

{
  # Skills de agentes declarativas (modelo nix-flatpak). Ver ./skills.nix.
  imports = [ ./skills.nix ];

  home.username = "cawal";
  home.homeDirectory = "/home/cawal";

  # NÃO mudar após a 1ª ativação (contrato de compatibilidade do HM).
  home.stateVersion = "26.05";

  # Deixa o HM se autogerenciar (comando `home-manager` opcional; aqui roda
  # acoplado ao nixos-rebuild).
  programs.home-manager.enable = true;

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Pacotes de usuário (HM). `obsidian-yazi` é o dispatcher dos atalhos `o …`
  # do yazi (definido no `let` acima).
  home.packages = [
    obsidian-yazi
    set-wallpaper
  ];

  # =========================================================================
  # PILOTO: yazi via módulo HM (plugins do nixpkgs, config lida dos seus TOMLs)
  # =========================================================================
  # O HM gera ~/.config/yazi/ a partir daqui. Os plugins vêm PRONTOS do
  # nixpkgs (nada de vendorizar). Os keymap/theme/settings são os seus TOMLs
  # de sempre — apenas lidos com fromTOML, então continuam arquivos editáveis
  # no repo (em nixos/home/yazi/).
  #
  # ATENÇÃO: com isto, o HM passa a ser DONO de ~/.config/yazi. O pacote stow
  # `yazi/` (na raiz do dotfiles) e o alvo `link-yazi` do Makefile devem sair
  # depois que confirmar que funciona (senão os dois brigam pelo diretório).
  programs.yazi = {
    enable = true;

    # yazi.toml / keymap.toml / theme.toml — seus arquivos, lidos como attrset.
    settings = builtins.fromTOML (builtins.readFile ./yazi/yazi.toml);
    keymap   = builtins.fromTOML (builtins.readFile ./yazi/keymap.toml);
    theme    = builtins.fromTOML (builtins.readFile ./yazi/theme.toml);

    # init.lua (require("git"):setup, etc.) — referenciado como caminho.
    initLua = ./yazi/init.lua;

    # Plugins declarativos, versionados junto do nixpkgs. O nome do atributo
    # vira o diretório <nome>.yazi, casando com os require()/plugin do config.
    plugins = {
      inherit (pkgs.yaziPlugins)
        git
        mount
        smart-enter
        chmod
        smart-filter
        ;
    };
  };

  # =========================================================================
  # mimeapps — associações de tipos MIME / handlers de URL (declarativo)
  # =========================================================================
  # Fonte de verdade dos apps padrão. Antes era um mimeapps.list stowado, mas
  # symlink de arquivo solto em ~/.config é frágil: apps GTK salvam via
  # temp+rename() e trocam o symlink por arquivo real. Aqui o HM é dono —
  # mesmo que a GUI reescreva ~/.config/mimeapps.list, o próximo rebuild
  # restaura. Para mudar um default de forma permanente, edite este bloco
  # (mudança pela GUI é transitória, some no próximo switch).
  #
  # NOTA sobre defaults explícitos: calibre e google-chrome declaram listas
  # MimeType enormes/genéricas nos .desktop (do nixpkgs). Sem um default
  # explícito, o xdg escolhe o 1º candidato em ORDEM ALFABÉTICA — por isso
  # `calibre-ebook-edit` (editor!) ganhava de `-viewer`, e `com.google.Chrome`
  # (Flatpak) pegava xml/rss. A correção é fixar cada tipo no app certo abaixo.
  # Regra: calibre SÓ para ebooks; PDF/DjVu/HQ → zathura; docx/odt/rtf → writer.
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # --- Web / browser (Zen) ---
      "text/html" = "zen.desktop";
      "application/xhtml+xml" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/chrome" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";    # era firefox_firefox (inexistente)
      "x-scheme-handler/unknown" = "zen.desktop";  # era firefox_firefox (inexistente)
      "application/x-extension-htm" = "zen.desktop";
      "application/x-extension-html" = "zen.desktop";
      "application/x-extension-shtml" = "zen.desktop";
      "application/x-extension-xhtml" = "zen.desktop";
      "application/x-extension-xht" = "zen.desktop";

      # --- Imagens (Loupe; era eog, que não existe mais no GNOME atual) ---
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
      "image/tiff" = "org.gnome.Loupe.desktop";
      "image/bmp" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";

      # --- PDF / DjVu / HQ → Zathura (tira do calibre e do Papers) ---
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/vnd.djvu" = "org.pwmt.zathura-djvu.desktop";
      "image/vnd.djvu+multipage" = "org.pwmt.zathura-djvu.desktop";
      "application/x-cbz" = "org.pwmt.zathura-cb.desktop";
      "application/x-cbr" = "org.pwmt.zathura-cb.desktop";
      "application/x-cb7" = "org.pwmt.zathura-cb.desktop";
      "application/x-cbc" = "org.pwmt.zathura-cb.desktop";

      # --- Documentos de escritório → LibreOffice Writer (tira do calibre) ---
      "application/vnd.oasis.opendocument.text" = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
      "application/vnd.ms-word.document.macroenabled.12" = "writer.desktop";
      "text/rtf" = "writer.desktop";

      # --- Ebooks → Calibre viewer (era -edit por causa da ordem alfabética) ---
      "application/epub+zip" = "calibre-ebook-viewer.desktop";
      "application/x-mobipocket-ebook" = "calibre-ebook-viewer.desktop";
      "application/x-mobipocket-subscription" = "calibre-ebook-viewer.desktop";
      "application/x-mobi8-ebook" = "calibre-ebook-viewer.desktop";
      "application/ereader" = "calibre-ebook-viewer.desktop";
      "application/oebps-package+xml" = "calibre-ebook-viewer.desktop";
      "application/x-sony-bbeb" = "calibre-ebook-viewer.desktop";
      "text/fb2+xml" = "calibre-ebook-viewer.desktop";

      # --- Texto (tira text/x-markdown do calibre) ---
      "text/plain" = "org.gnome.TextEditor.desktop";
      "text/markdown" = "org.gnome.TextEditor.desktop";
      "text/x-markdown" = "org.gnome.TextEditor.desktop";

      # --- Handlers de esquema (apps próprios) ---
      "x-scheme-handler/opencode" = "ai.opencode.desktop.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "x-scheme-handler/slack" = "slack.desktop";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      # x-scheme-handler/postman removido: Postman.desktop não existe no sistema.
    };

    # Remove o calibre da LISTA de candidatos (menu "Abrir com") desses tipos —
    # reforça que ebook-app não deve nem aparecer como opção para doc/pdf/imagem.
    associations.removed = {
      "application/pdf" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
      "image/vnd.djvu" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
      "text/plain" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
      "text/x-markdown" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
      "text/rtf" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "calibre-ebook-viewer.desktop" "calibre-gui.desktop" ];
    };
  };

  # =========================================================================
  # PADRÃO 2 (exemplos comentados): migrar o RESTO dos dotfiles do stow
  # =========================================================================
  # mkOutOfStoreSymlink aponta ~/.config/<x> DIRETO para o seu repo — edição
  # ao vivo, sem rebuild para mudar conteúdo. É o equivalente declarativo do
  # `make link-<x>`. Descomente conforme for migrando cada pacote:
  #
  # xdg.configFile."kitty".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/git/cwl-dotfiles/kitty";
  #
  # xdg.configFile."ranger".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/git/cwl-dotfiles/ranger";
  #
  # xdg.configFile."rofi".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/git/cwl-dotfiles/rofi";
  #
  # Arquivos direto no $HOME (não em ~/.config) usam home.file:
  # home.file.".zshrc".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/git/cwl-dotfiles/zsh/.zshrc";
}
