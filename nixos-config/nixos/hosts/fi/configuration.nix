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
