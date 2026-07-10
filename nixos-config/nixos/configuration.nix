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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
     keyd
     arandr
     xrandr
  ];

services.keyd = {
  enable = true;
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
