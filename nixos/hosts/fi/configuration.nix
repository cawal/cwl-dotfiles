# Fi - Desktop configuration with NVIDIA GPU
# Host-specific settings for the 'fi' machine

{ config, pkgs, ... }:

{
  imports = [
    # Hardware scan (will be added when installing NixOS on fi)
    ./hardware-configuration.nix
    
    # Common configurations shared across all hosts
    ../../common/base.nix
    ../../common/desktop.nix
    ../../common/development.nix
    ../../common/services.nix
    
    # Fi-specific modules
    ../../modules/nvidia.nix    # NVIDIA GPU drivers + CUDA (RTX 4060, PRIME offload)
    ../../modules/gaming.nix    # Steam, emulators, gaming tools
  ];

  # Hostname
  networking.hostName = "fi";

  # Hibernação: swap fica no LV pool-swap (dentro do LUKS). O initrd destrava o
  # LUKS antes de retomar. Ver hosts/fi/disko.nix (swapSize = 24G).
  boot.resumeDevice = "/dev/mapper/pool-swap";
  # DPI base do painel interno (eDP-1 nativo 2560x1600, HiDPI). Baseline do
  # layout single-monitor. O screenlayout-fi-double-monitor.sh sobrescreve para
  # Xft.dpi 96 via xrdb, pois usa --scale (1680x1050 aparente, densidade normal).
  services.xserver.dpi = 144;

  # Syncthing data directory (specific to this host)
  services.syncthing.dataDir = "/var/lib/syncthing-fi";
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # AI/ML tools that benefit from CUDA
    # ollama              # Run LLMs locally (uncomment when needed)
    # blender             # 3D creation suite (CUDA acceleration)
    
    # Additional gaming/media tools
    # obs-studio          # Screen recording/streaming
  ];
  
  # Host-specific overrides (if needed)
  # Example: Kernel parameters for NVIDIA
  # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}
