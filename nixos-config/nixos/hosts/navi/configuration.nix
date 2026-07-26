# Navi - Laptop configuration
# Host-specific settings for the 'navi' machine

{ config, pkgs, ... }:

{
  imports = [
    # Hardware scan
    ./hardware-configuration.nix
    
    # Common configurations shared across all hosts
    ../../common/base.nix
    ../../common/desktop.nix
    ../../common/development.nix
    ../../common/services.nix
    
    # Navi doesn't have NVIDIA, so we don't import nvidia.nix
    # Navi doesn't need gaming module
  ];

  # Hostname
  networking.hostName = "navi";
  
  # Syncthing data directory (specific to this host)
  services.syncthing.dataDir = "/var/lib/syncthing";
  
  # Host-specific packages (if any)
  environment.systemPackages = with pkgs; [
    # Add navi-specific packages here
  ];
  
  # Host-specific overrides (if needed)
  # Example: boot.kernelParams = [ "specific-param" ];
}
