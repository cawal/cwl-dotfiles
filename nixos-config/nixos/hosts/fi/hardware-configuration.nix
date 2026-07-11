# Placeholder hardware configuration for 'fi'
# 
# This file will be replaced when NixOS is installed on the 'fi' machine.
# To generate the real hardware config on 'fi':
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# Then copy it to: nixos-config/nixos/hosts/fi/hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];
  
  # Placeholder - will be replaced with actual hardware scan
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];
  
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
