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
      
      # Fi - Desktop with NVIDIA GPU + Gaming setup
      fi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/hosts/fi/configuration.nix ];
      };
    };
  };
}
