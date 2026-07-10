{
  description = "Nix Configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.navi = nixpkgs.lib.nixosSystem {
      modules = [ ./nixos/configuration.nix ];
    };
  };
}
