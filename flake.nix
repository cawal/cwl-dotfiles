{
  description = "CWL NixOS Configurations - Multi-host setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Particionamento declarativo (LVM-on-LUKS, /home separado).
    # Wiring do disko na master p/ ambos os hosts. Ver AGENTS.md → disko.
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager: gestão declarativa de dotfiles do usuário. Release casado
    # com o nixpkgs (26.05) para evitar divergência de módulos.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Zen Browser: não está no nixpkgs. Flake recomendado pelo wiki do NixOS
    # (https://wiki.nixos.org/wiki/Zen_Browser). Segue nosso nixpkgs.
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Herdr: não está no nixpkgs. Flake oficial (herdr.dev), fixado na tag de
    # release. Para atualizar: bump da tag aqui + `nix flake update herdr`.
    herdr.url = "github:herdrdev/herdr/v0.7.5";
    herdr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, disko, home-manager, zen-browser, herdr }:
    let
      # Módulo home-manager compartilhado por todos os hosts. Ativa junto do
      # nixos-rebuild; a config do usuário vive em ./nixos/home/cawal.nix.
      homeManager = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.cawal = import ./nixos/home/cawal.nix;
      };
      pkgsUnstable = import nixpkgs-unstable {
        system = "x86_64-linux"; 
        config.allowUnfree = true;
      };
    in
    {
    nixosConfigurations = {
      # Navi - Laptop without NVIDIA
      navi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Disponibiliza inputs do flake (ex.: zen-browser) para os módulos.
        specialArgs = { inherit zen-browser herdr pkgsUnstable; };
        # disko é dono do particionamento (LVM-on-LUKS). Instalado — `switch` é
        # seguro (o pool /dev/mapper/pool-* existe). Só num disco NOVO sem o pool
        # use `nixos-install`, nunca `switch`. Ver AGENTS.md.
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/navi/disko.nix
          ./nixos/hosts/navi/configuration.nix

          home-manager.nixosModules.home-manager
          homeManager
        ];
      };
      
      # Fi - Laptop with NVIDIA GPU + Gaming setup
      # disko é dono do particionamento (LVM-on-LUKS + LV Docker). Instalado —
      # `switch` é seguro (o pool existe). Só num disco NOVO sem o pool use
      # `nixos-install`, nunca `switch`. Ver AGENTS.md.
      fi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Disponibiliza inputs do flake (ex.: zen-browser) para os módulos.
        specialArgs = { inherit zen-browser herdr pkgsUnstable; };
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
