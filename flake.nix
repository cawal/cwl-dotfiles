{
  description = "CWL NixOS Configurations - Multi-host setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # Particionamento declarativo (LVM-on-LUKS, /home separado).
    # Só entra no build de um host que importe seu módulo (ver branch navi-disko).
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager: gestão declarativa de dotfiles do usuário. Release casado
    # com o nixpkgs (26.05) para evitar divergência de módulos.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager }:
    let
      # Módulo home-manager compartilhado por todos os hosts. Ativa junto do
      # nixos-rebuild; a config do usuário vive em ./nixos/home/cawal.nix.
      homeManager = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.cawal = import ./nixos/home/cawal.nix;
      };
    in
    {
    nixosConfigurations = {
      # Navi - Laptop without NVIDIA
      navi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Branch navi-disko: disko é dono do particionamento (LVM-on-LUKS).
        # Só usar via `nixos-install` no live USB — NÃO `nixos-rebuild switch`
        # no sistema atual (disco ainda é LUKS cru). Ver AGENTS.md.
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/navi/disko.nix
          ./nixos/hosts/navi/configuration.nix

          home-manager.nixosModules.home-manager
          homeManager
        ];
      };
      
      # Fi - Laptop with NVIDIA GPU + Gaming setup
      # Branch fi-disko: disko é dono do particionamento (LVM-on-LUKS + LV Docker).
      # Só usar via `nixos-install` no live USB — NÃO `nixos-rebuild switch` num
      # sistema cujo disco ainda não tem o pool. Ver AGENTS.md.
      fi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/fi/disko.nix
          ./nixos/hosts/fi/configuration.nix

          home-manager.nixosModules.home-manager
          homeManager
        ];
      };
    };
  };
}
