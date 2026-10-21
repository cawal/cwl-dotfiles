{
  description = "CWL NixOS Configurations - Multi-host setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Input dedicado só para o Electron 44 (exigido pelo Granola, ver
    # common/granola.nix). O electron_44 só apareceu num rev recente do unstable,
    # ausente tanto no estável quanto no rev fixado em nixpkgs-unstable. Não faz
    # follows para não ser arrastado pelo pin do outro. Bump: nix flake update
    # nixpkgs-electron.
    nixpkgs-electron.url = "github:nixos/nixpkgs/nixos-unstable";

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
    herdr.url = "github:herdrdev/herdr/v0.9.5";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # llmfit: TUI que casa modelos LLM ao hardware. Não está no nixpkgs; usa o
    # flake oficial. Segue nosso nixpkgs p/ não puxar um segundo nixpkgs no lock.
    llmfit.url = "github:AlexsJones/llmfit";
    llmfit.inputs.nixpkgs.follows = "nixpkgs";

    # nix-flatpak: gestão declarativa de remotes/apps Flatpak (o módulo do
    # NixOS só liga o daemon; remotes e apps seriam imperativos sem isto).
    # Ver wiki: https://wiki.nixos.org/wiki/Flatpak. Config em common/services.nix.
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-electron, disko, home-manager, zen-browser, herdr, llmfit, nix-flatpak }:
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
        # O Zotero 10 embute o Firefox ESR 140 como engine (o binário se reporta
        # como "Zotero 140.x.0esr"), e o nixpkgs passou a marcar esse ESR como
        # insecure por fim de suporte. Sem esta permissão a avaliação do sistema
        # INTEIRO falha, porque desktop.nix usa pkgsUnstable.zotero.
        #
        # Por que permitir e não recuar: o estável 26.05 tem Zotero 9.0.6, e já
        # rodamos o 10 — o Zotero migra o schema do ~/Zotero/zotero.sqlite na
        # subida e recusa abrir biblioteca de versão mais nova, então voltar pro
        # 9 quebraria a biblioteca. E o 10.0.2 que já está instalado embute o ESR
        # 140.16: permitir isto não aumenta a exposição, só destrava o nixpkgs
        # que começou a sinalizá-la.
        #
        # RISCO REAL a monitorar: a engine embutida do Zotero (leitor de PDF e
        # captura de páginas) roda num ESR fora de suporte. É problema do upstream
        # do Zotero; revisar quando eles trocarem de base.
        config.permittedInsecurePackages = [
          "firefox-esr-140-bin-unwrapped-140.17.0esr"
        ];
      };
      # Só para o Electron 44 do Granola (ver common/granola.nix).
      pkgsElectron = import nixpkgs-electron {
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
        specialArgs = { inherit zen-browser herdr llmfit pkgsUnstable pkgsElectron; };
        # disko é dono do particionamento (LVM-on-LUKS). Instalado — `switch` é
        # seguro (o pool /dev/mapper/pool-* existe). Só num disco NOVO sem o pool
        # use `nixos-install`, nunca `switch`. Ver AGENTS.md.
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/navi/disko.nix
          ./nixos/hosts/navi/configuration.nix

          home-manager.nixosModules.home-manager
          homeManager

          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
      
      # Fi - Laptop with NVIDIA GPU + Gaming setup
      # disko é dono do particionamento (LVM-on-LUKS + LV Docker). Instalado —
      # `switch` é seguro (o pool existe). Só num disco NOVO sem o pool use
      # `nixos-install`, nunca `switch`. Ver AGENTS.md.
      fi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Disponibiliza inputs do flake (ex.: zen-browser) para os módulos.
        specialArgs = { inherit zen-browser herdr llmfit pkgsUnstable pkgsElectron; };
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/fi/disko.nix
          ./nixos/hosts/fi/configuration.nix

          home-manager.nixosModules.home-manager
          homeManager

          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
  };
}
