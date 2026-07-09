{
  description = "Nix Consiguration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.navi = nixpkgs.lib.nixosSystem {
      modules = [ ./nixos/configuration.nix ];
    };
  };
}
