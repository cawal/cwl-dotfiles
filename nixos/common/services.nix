# System services configuration
# Bluetooth, Syncthing, keyd, Greenclip, Qtile, Printing, Sound

{ config, pkgs, ... }:

{
  # === Sound ===
  
  # Disable PulseAudio (using Pipewire instead)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  
  # Enable Pipewire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # === Printing ===

  services.printing.enable = true;

  # === Firmware updates (paridade com o Ubuntu) ===
  # Daemon fwupd + LVFS. CLI: `fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update`.
  # Em ambientes GNOME o GNOME Software também mostra e notifica as atualizações.
  services.fwupd.enable = true;

  # === Flatpak (declarativo via nix-flatpak) ===
  # O módulo do NixOS (services.flatpak.enable) só sobe o daemon; os `remotes` e
  # `packages` abaixo vêm do módulo nix-flatpak (input no flake.nix da raiz) e são
  # aplicados por um serviço de ativação a cada rebuild — mantendo o Flatpak tão
  # declarativo quanto o resto da config. O portal XDG necessário já vem do GNOME
  # (xdg-desktop-portal-gtk). Ver wiki: https://wiki.nixos.org/wiki/Flatpak.
  services.flatpak = {
    enable = true;

    # Remote oficial Flathub. (O nix-flatpak já traz o flathub por padrão, mas
    # deixamos explícito para o remote não depender de estado imperativo.)
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    # Apps instalados/atualizados declarativamente no rebuild.
    # https://flathub.org/apps/com.redis.RedisInsight
    # https://flathub.org/apps/io.github.alamahant.Asteria
    packages = [
      "com.redis.RedisInsight"
      "io.github.alamahant.Asteria"
    ];
  };

  # === Bluetooth ===
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # === Clipboard Manager ===
  
  services.greenclip.enable = true;

  # O módulo só põe o greenclip em WantedBy=graphical-session.target, então
  # parar o target não para o serviço. No fim da sessão o X sumia, o greenclip
  # caía em loop de restart (`Restart=always`), estourava o start-limit e ficava
  # morto até alguém dar reset-failed (aconteceu em 2026-11-06). Com PartOf ele
  # para e sobe junto com a sessão gráfica (ver qtile-session.target abaixo).
  systemd.user.services.greenclip.partOf = [ "graphical-session.target" ];

  # === Syncthing ===
  # Note: Folders and devices configured via web UI (http://localhost:8384)
  
  services.syncthing = {
    enable = true;
    user = "cawal";
    group = "users";
    openDefaultPorts = true;  # Opens 22000 (TCP), 21027 (UDP)
    guiAddress = "0.0.0.0:8384";  # GUI faz bind em todas as interfaces
    # dataDir will be set per-host in hosts/*/configuration.nix

    # Folders/devices seguem gerenciados pela GUI — NÃO deixar o módulo
    # sobrescrevê-los. Sem isso, o settings abaixo apagaria tudo o que foi
    # configurado pela web UI (overrideDevices/Folders default = true).
    overrideDevices = false;
    overrideFolders = false;

    # IMPORTANTE: NÃO declarar `settings.gui.*` aqui.
    # O módulo do NixOS cria o serviço `syncthing-init`, que a cada rebuild/boot
    # faz `curl -X PUT '{"tls":true}' /rest/config/gui`. Como o PUT SUBSTITUI o
    # objeto GUI inteiro, ele apagava o user/password configurados pela web UI
    # (voltava a mensagem "sem senha"). Sem nenhum `settings.gui`, o init não
    # toca na GUI e user/password/tls persistem no config.xml.
    #
    # HTTPS na GUI: habilite uma vez pela web UI (Settings → GUI → "Use HTTPS
    # for GUI"). O Syncthing gera um cert self-signed em <config>/https-cert.pem
    # e o navegador vai avisar que não é confiável (esperado); aceite a exceção.
  };

  # Libera a GUI do Syncthing (8384) na LAN. O bind 0.0.0.0 acima só escuta;
  # é o firewall que abre a porta. openDefaultPorts abre 22000/21027 (sync),
  # mas NÃO a 8384 — daí a regra explícita aqui.
  networking.firewall.allowedTCPPorts = [ 8384 ];

  # Ensure Syncthing directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d ${config.services.syncthing.dataDir} 0700 cawal users -"
    "d ${config.services.syncthing.dataDir}/.config 0700 cawal users -"
    "d ${config.services.syncthing.dataDir}/.config/syncthing 0700 cawal users -"
  ];

  # === Keyd - Keyboard remapping daemon ===
  
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];  # Apply to all keyboards
        
        settings = {
          global = {
            macro_timeout = 600;
            macro_repeat_timeout = 50;
            layer_indicator = 1;
            chord_timeout = 50;
            chord_hold_timeout = 0;
            oneshot_timeout = 0;
            disable_modifier_guard = 0;
            overload_tap_timeout = 200;
          };
          
          main = {
            # Maps capslock to escape when pressed and nav layer when held
            capslock = "overload(nav, esc)";
            
            # Space acts as Meta when held
            space = "lettermod(meta, space, 150, 200)";
            
            # Remap insert to Shift+Insert (paste on X11)
            insert = "S-insert";
          };
          
          "nav:C" = {
            # Navigation arrows on home row (vim-style)
            h = "left";
            j = "down";
            k = "up";
            l = "right";
            
            # Additional navigation
            u = "home";
            i = "end";
          };
        };
      };
    };
  };

  # === Sessão systemd do qtile ===
  # O qtile (WM puro) não ativa o graphical-session.target como um DE (gnome-session)
  # faria — então serviços user `WantedBy=graphical-session.target` (ex.: greenclip)
  # ficavam `enabled` mas nunca subiam no login. O graphical-session.target recusa
  # start manual (RefuseManualStart); o padrão systemd é um target de sessão próprio
  # que faz BindsTo dele. O qtile inicia o `qtile-session.target` no startup (ver
  # bin/cwl-startup-processes.sh: import-environment + `systemctl --user start`),
  # o que puxa o graphical-session.target como dependência e ativa os serviços.
  systemd.user.targets.qtile-session = {
    description = "qtile session";
    bindsTo = [ "graphical-session.target" ];
    before = [ "graphical-session.target" ];
  };

  # === Qtile Window Manager ===

  services.xserver.windowManager.qtile = {
    enable = true;
    
    # Override Qtile to skip tests (speeds up build)
    package = pkgs.python3Packages.qtile.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;

      # Desde o 0.37 a sessão Wayland do pacote se chama `qtile.desktop`, o
      # mesmo nome da X11 (antes era `qtile-wayland.desktop`). O GDM lembra a
      # sessão pelo nome, resolve para a Wayland e o login cai numa tela vazia,
      # porque a config daqui é X11 (xlib, greenclip). Renomear a Wayland de
      # volta para `qtile-wayland` faz "qtile" ser só a X11 de novo e mantém a
      # Wayland no menu de sessões do GDM, como "Qtile (Wayland)".
      postInstall = (oldAttrs.postInstall or "") + ''
        mv $out/share/wayland-sessions/qtile.desktop \
           $out/share/wayland-sessions/qtile-wayland.desktop
        sed -i 's/^Name=Qtile$/Name=Qtile (Wayland)/' \
           $out/share/wayland-sessions/qtile-wayland.desktop
      '';
    });

    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      xlib
    ];
  };
}
