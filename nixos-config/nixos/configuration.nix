# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.initrd.luks.devices."luks-c68bbcad-9bcf-42a6-bc1b-6850e9742923".device = "/dev/disk/by-uuid/c68bbcad-9bcf-42a6-bc1b-6850e9742923";
  networking.hostName = "navi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."cawal" = {
    isNormalUser = true;
    description = "cawal";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;  # Set zsh as default shell
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    # Oh My Zsh integration
    ohMyZsh = {
      enable = true;
      theme = "agnoster";  # Matches your .zshrc
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

  # Enable AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true;  # Allows running AppImages like regular executables
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;  # Start Docker daemon on boot
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # Power on Bluetooth adapter on boot
  };
  services.blueman.enable = true;  # Blueman GUI for managing Bluetooth

  # Greenclip - Clipboard manager
  services.greenclip.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     # Core tools (already installed)
     neovim
     google-chrome
     opencode
     jq
     kitty
     tmux
     ranger
     xclip
     slack
     wget
     gnumake
     gcc
     fzf
     ripgrep
     stow
     git
     gh
     zsh
     rofi
     nitrogen
     arandr
     xrandr

     # === FASE 3: Pacotes essenciais do workflow ===
     
     # Node.js ecosystem
     nodejs_22           # Node.js (LTS)
     pnpm                # pnpm package manager (now at top level)
     # npx comes with nodejs
     mermaid-cli         # Mermaid diagrams CLI (now at top level)
     
     # Java & Diagram tools
     jre                 # Java Runtime (for PlantUML)
     plantuml            # PlantUML diagrams
     graphviz            # Dependency for PlantUML
     
     # Cloud & Infrastructure
     google-cloud-sdk    # gcloud CLI
     kubectl             # Kubernetes CLI
     kubernetes-helm     # Helm package manager
     (terraform.overrideAttrs (oldAttrs: {
       doCheck = false;  # Skip tests to speed up build
     }))
     
     # Data tools
     yq-go               # YAML/JSON processor (Go version)
     q-text-as-data      # Query CSV files with SQL
     
     # Search & CLI tools
     silver-searcher     # ag - code search tool
     
     # Desktop utilities
     # greenclip - managed as service (services.greenclip.enable)
     gpick               # Color picker
     
     # Development tools
     vscode              # Visual Studio Code
     postman             # API testing
     insomnia            # API client
     dbeaver-bin         # Database manager
     
     # Python tools
     uv                  # Fast Python package installer
     python3
     python3Packages.pip
     # pipx - temporarily disabled due to failing tests in 1.8.0
     # Can install with: pip install --user pipx
     
     # Communication & Entertainment
     discord             # Chat
     retroarch           # Gaming emulator frontend
     
     # Additional CLI tools
     httpie              # HTTP client
     entr                # Run commands when files change
     csvkit              # CSV manipulation tools
     cloc                # Count lines of code
     shellcheck          # Shell script linter
     xdotool             # X11 automation tool
     htop                # Process viewer
     
     # Desktop environment (i3/qtile related)
     i3lock              # Screen locker
     dunst               # Notification daemon
     picom               # Compositor
     flameshot           # Screenshot tool
     lxappearance        # GTK theme switcher
     pavucontrol         # PulseAudio volume control
     
     # Browsers
     qutebrowser         # Keyboard-driven browser
     
     # Productivity
     libreoffice         # Office suite
     keepassxc           # Password manager
     
     # Media tools
     vlc                 # Media player
     audacity            # Audio editor
     inkscape            # Vector graphics
     gimp                # Image editor
     imagemagick         # Image manipulation CLI
     calibre             # E-book manager
     
     # File management
     file-roller         # Archive manager
     baobab              # Disk usage analyzer
     
     # Network tools
     networkmanagerapplet  # NetworkManager tray icon
     tcpflow             # TCP flow recorder
     tmate               # Terminal sharing
  ];

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

services.xserver.windowManager.qtile = {
  enable = true;
  
  # 1. Puxando o Qtile de dentro de python3Packages para aplicar o override
  package = pkgs.python3Packages.qtile.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
  });

  extraPackages = python3Packages: with python3Packages; [
    qtile-extras
    xlib
  ];
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		openFirewall = true;
		settings = {
			PasswordAuthentication = true;
			KbdInteractiveAuthentication = true;
			PermitRootLogin = "no";
			AllowUsers = [ "cawal" ];
			MaxAuthTries = 3;
			PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
		};
	};
# Enable mDNS (Avahi) for .local resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Resolves .local hostnames for IPv4
    openFirewall = true; # Opens necessary UDP ports (5353)
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Syncthing - accessible both locally and over network
  services.syncthing = {
    enable = true;
    user = "cawal";
    dataDir = "/home/cawal/.syncthing";
    configDir = "/home/cawal/.config/syncthing";
    openDefaultPorts = true; # Opens 22000 (TCP), 21027 (UDP)
    guiAddress = "0.0.0.0:8384"; # Accessible from network (password protected via Syncthing UI)
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
