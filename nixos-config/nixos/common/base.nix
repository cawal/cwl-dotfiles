# Base system configuration shared across all hosts
# Core settings: bootloader, networking, locale, users, system packages

{ config, pkgs, ... }:

{
  # Bootloader - systemd-boot with EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking via NetworkManager
  networking.networkmanager.enable = true;

  # Enable mDNS (Avahi) for .local hostnames
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;  # Opens UDP port 5353
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      # domain/hinfo/userServices deixados desligados para casar com o
      # sistema atual do navi (evita expor CPU/OS e serviços de usuário
      # via mDNS). Religar aqui se precisar de descoberta mais rica.
    };
  };

  # Enable OpenSSH daemon
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

  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Locale settings
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

  # Keyboard layout
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";

  # Enable Nix flakes and new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection automático: remove gerações antigas semanalmente para
  # manter o /nix/store (no /) enxuto. Troque 30d p/ 15d se quiser mais agressivo.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  # Deduplica arquivos idênticos no /nix/store por hardlink.
  nix.optimise.automatic = true;

  # Define user account
  users.users."cawal" = {
    isNormalUser = true;
    description = "cawal";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$xdrSPGQv8tiSI.E5$qqhLAACbeTvf9v8dNirNBQBISHXdj9BHG4NkjjBMuUS7HTnn8YfbPlG41/rD7owDWc1jTlgc3yxkWbhqgwR.00";
  };

  users.mutableUsers = true;

  # Enable nix-ld to run unpatched dynamic binaries on NixOS
  # This allows tools like Mason (neovim) to install compiled binaries
  # Reference: https://github.com/Mic92/nix-ld
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
    glib
    libgcc
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Core system packages - tools needed on all machines
  environment.systemPackages = with pkgs; [
    # Core CLI tools
    neovim
    git
    gh                  # GitHub CLI
    delta               # Diff pager
    wget
    curl
    jq                  # JSON processor
    fzf                 # Fuzzy finder
    ripgrep             # Fast grep alternative
    stow                # Dotfiles symlink manager
    psmisc              # killall, fuser, pstree, etc
    gnumake
    gcc
    
    # Terminal & multiplexer
    kitty               # GPU-accelerated terminal
    tmux                # Terminal multiplexer
    tmate               # Terminal sharing
    zsh                 # Shell
    
    # File management
    ranger              # Terminal file manager
    xclip               # Clipboard utility
    
    # System monitoring
    htop
    iotop
    
    # Network tools
    nmap
    traceroute
    dig
    networkmanagerapplet  # nm-applet tray icon
    tcpflow               # TCP flow recorder
    
    # Archive tools
    unzip
    zip
    p7zip
    
    # Browser
    google-chrome
  ];

  # Firefox managed by the NixOS module (generates policies.json, native
  # messaging hosts) — matches the monolith's `programs.firefox.enable`.
  programs.firefox.enable = true;

  # System version (for reference)
  system.stateVersion = "26.05";
}
