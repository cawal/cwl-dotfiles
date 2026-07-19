# STUB de hardware do fi (branch de instalação fi-disko).
#
# fileSystems, swapDevices e boot.initrd.luks.devices são fornecidos pelo disko
# (ver ./disko.nix + ../../common/disko-lvm-luks.nix). NÃO os defina aqui.
#
# Este arquivo é um stub para permitir avaliar/validar a config antes do install.
# SUBSTITUA-O pelo scan real durante a instalação no live USB:
#   sudo nixos-generate-config --no-filesystems --root /mnt
# (isso preenche os kernel modules corretos da máquina; os abaixo são um mínimo
#  razoável p/ NVMe + Intel Core Ultra "Meteor Lake" só para não deixar o initrd
#  sem o driver de NVMe caso o passo acima seja esquecido.)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
