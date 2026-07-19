{
  description = "CWL NixOS Configurations - Multi-host setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # Particionamento declarativo (LVM-on-LUKS, /home separado).
    # Só entra no build de um host que importe seu módulo (ver branch navi-disko).
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko }: {
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
        ];
      };
    };
  };
}
