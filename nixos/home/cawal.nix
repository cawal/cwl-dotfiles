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
  home.username = "cawal";
  home.homeDirectory = "/home/cawal";

  # NÃO mudar após a 1ª ativação (contrato de compatibilidade do HM).
  home.stateVersion = "26.05";

  # Deixa o HM se autogerenciar (comando `home-manager` opcional; aqui roda
  # acoplado ao nixos-rebuild).
  programs.home-manager.enable = true;

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
