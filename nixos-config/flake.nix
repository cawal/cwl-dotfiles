{
  description = "CWL NixOS Configurations - Multi-host setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # Navi - Laptop without NVIDIA
      navi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/hosts/navi/configuration.nix ];
      };
      
      # Fi - Desktop with NVIDIA GPU + Gaming setup
      fi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/hosts/fi/configuration.nix ];
      };
    };
  };
}
