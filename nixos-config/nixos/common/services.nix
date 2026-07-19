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

  # === Bluetooth ===
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # === Clipboard Manager ===
  
  services.greenclip.enable = true;

  # === Syncthing ===
  # Note: Folders and devices configured via web UI (http://localhost:8384)
  
  services.syncthing = {
    enable = true;
    user = "cawal";
    group = "users";
    openDefaultPorts = true;  # Opens 22000 (TCP), 21027 (UDP)
    guiAddress = "0.0.0.0:8384";  # Accessible from network
    # dataDir will be set per-host in hosts/*/configuration.nix
  };

  # Ensure Syncthing directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/syncthing 0700 cawal users -"
    "d /var/lib/syncthing/.config 0700 cawal users -"
    "d /var/lib/syncthing/.config/syncthing 0700 cawal users -"
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

  # === Qtile Window Manager ===
  
  services.xserver.windowManager.qtile = {
    enable = true;
    
    # Override Qtile to skip tests (speeds up build)
    package = pkgs.python3Packages.qtile.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;
    });

    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      xlib
    ];
  };
}
