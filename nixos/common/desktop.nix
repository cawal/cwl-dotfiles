# Desktop environment configuration
# GNOME, Qtile, Picom, GTK/Qt theming, display tools

{ config, pkgs, zen-browser, ... }:

{
  imports = [
    ./fonts.nix   # fontes do sistema (Nerd Fonts, Noto)
  ];

  # Enable X11 windowing system
  services.xserver.enable = true;

  # Enable GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GTK and Qt theming - Dark theme preference
  programs.dconf.enable = true;  # Required for GTK settings
  
  # Qt theming - make Qt apps use GTK theme
  qt = {
    enable = true;
    platformTheme = "gtk2";  # Makes Qt apps follow GTK theme
    style = "adwaita-dark";
  };

  # Environment variables for theming
  environment.sessionVariables = {
    # Qt theming
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    
    # GTK theme preference - Adwaita dark (reliable on NixOS)
    GTK_THEME = "Adwaita:dark";
    GTK_ICON_THEME = "Papirus-Dark";

    # Na sessão qtile o XDG_CURRENT_DESKTOP vem vazio, e apps como o
    # gnome-control-center recusam rodar fora de GNOME/Unity ("Running ...
    # is only supported under GNOME and Unity, exiting"). O formato lista
    # `qtile:GNOME` faz o control-center enxergar o GNOME e liberar, mantendo
    # a sessão identificada como qtile para os demais apps/portals.
    XDG_CURRENT_DESKTOP = "qtile:GNOME";
  };

  # System activation script to set GTK dark theme via dconf
  # This runs on every nixos-rebuild to ensure theme is always set
  system.activationScripts.setGtkTheme = ''
    # Set GTK theme to Adwaita-dark for all users
    for user_home in /home/*; do
      if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        # Run as user to set dconf settings
        sudo -u $user ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'" 2>/dev/null || true
        sudo -u $user ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
        sudo -u $user ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'" 2>/dev/null || true
      fi
    done
  '';

  # Enable i3lock via programs module (fixes PAM authentication)
  # Reference: https://github.com/NixOS/nixpkgs/pull/417193
  programs.i3lock.enable = true;

  # Destrava o gnome-keyring automaticamente no login do GDM.
  # O módulo GNOME só adiciona o pam_gnome_keyring ao PAM `login` (console),
  # não ao `gdm-password` (caminho real da tela do GDM) — por isso o chaveiro
  # ficava trancado e pedia senha ao acessar segredos (ex.: tokens OAuth do GOA
  # usados pelo gnome-calendar). Requer que a senha do chaveiro == senha de login.
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # Portal XDG — corrige o dialog de arquivos (FileChooser) que não abria no
  # Zen Browser e em outros apps sob a sessão qtile.
  # O portal escolhe o backend pelo XDG_CURRENT_DESKTOP; como aqui ele é
  # "qtile:GNOME" (ver sessionVariables acima) e não existe backend próprio do
  # qtile, o FileChooser ficava sem implementação e o dialog não aparecia.
  # Fixamos o backend gtk como default (equivale, no NixOS, ao
  # `pacman -S xdg-desktop-portal-gtk` + restart do serviço citado na thread
  # https://github.com/zen-browser/desktop/issues/7418).
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    # Oh My Zsh integration
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "kubectl"
        "helm"
        "terraform"
        "gcloud"
        "python"
        "pip"
        "systemd"
        "fzf"
      ];
    };
    
    # Environment variables that should be set system-wide
    shellInit = ''
      # Path additions (NixOS manages most of this automatically)
      export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
      
      # Load local config if it exists (for machine-specific settings)
      [[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"
    '';
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Window manager & desktop tools
    rofi                # Application launcher
    nitrogen            # Wallpaper manager
    dunst               # Notification daemon
    arandr              # GUI for xrandr
    xrandr              # Display configuration
    i3lock              # Screen locker
    betterlockscreen    # i3lock wrapper with blur effects
    flameshot           # Screenshot tool
    lxappearance        # GTK theme switcher
    pavucontrol         # PulseAudio volume control
    libnotify            # Notification library for apps
    
    # GTK and Qt theming
    adwaita-icon-theme       # GNOME icon theme
    papirus-icon-theme       # Papirus icon theme for GTK/Qt apps and tray icons
    gnome-themes-extra       # Adwaita-dark and other themes
    gtk-engine-murrine       # GTK2 theme engine
    libsForQt5.qtstyleplugin-kvantum  # Qt5 theming
    qt6Packages.qtstyleplugin-kvantum # Qt6 theming
    libsForQt5.qt5ct         # Qt5 configuration tool
    qt6Packages.qt6ct        # Qt6 configuration tool
    
    # GNOME apps (lightweight utilities)
    gnome-calendar
    gnome-characters      # Character map/emoji picker
    baobab                # Disk usage analyzer
    nautilus              # File manager
    file-roller           # Archive manager
    
    # Productivity apps
    obsidian              # Note-taking
    slack                 # Communication
    keepassxc             # Password manager
    libreoffice           # Office suite
    zathura               # PDF viewer
    zotero                # Reference manager
    homebank              # Finance manager
    calibre               # E-book manager
    
    # Communication
    discord
    telegram-desktop
    
    # Media
    vlc                   # Media player
    spotify               # Music streaming
    audacity              # Audio editor
    inkscape              # Vector graphics
    gimp                  # Image editor
    imagemagick           # Image manipulation CLI
    
    # Browsers
    qutebrowser           # Keyboard-driven browser
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default  # Zen (via flake, ver flake.nix)
    
    # Entertainment
    retroarch             # Emulator frontend
  ];
}
