# Overlay de pacotes próprios — coisas que não existem no nixpkgs.
#
# Aplicado em nixos/common/base.nix via `nixpkgs.overlays`, então vale para
# TODOS os hosts. Cada pacote vira `pkgs.<nome>` como se fosse do nixpkgs.
#
# Para adicionar uma nova CLI:
#   1. crie ./<nome>.nix (assinatura callPackage: { lib, stdenvNoCC, ... }:)
#   2. adicione `<nome> = final.callPackage ./<nome>.nix { };` abaixo
#   3. use em environment.systemPackages como `pkgs.<nome>`
#
# Padrão recomendado (ver ./ntn.nix): a maioria das CLIs npm/Bun/Go/Rust
# distribui um binário pré-compilado. Pegue-o com fetchurl + instale direto,
# em vez de node2nix/buildNpmPackage.
final: prev: {
  ntn = final.callPackage ./ntn.nix { };
}
