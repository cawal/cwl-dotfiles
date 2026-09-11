# Granola (app Electron macOS reempacotado para Linux). Ver nixos/pkgs/granola.nix.
#
# O Electron 44 (que o app exige) só existe no nixpkgs-unstable recente, não no
# nixpkgs estável (26.05) nem no rev de unstable fixado em pkgsUnstable. Por isso
# usamos um input dedicado (nixpkgs-electron) via pkgsElectron. Ver flake.nix.
#
# Handler do granola:// (callback de login): o desktop file abaixo declara o
# MimeType, o que registra o app como candidato. O default do usuário é definido
# em ~/.config/qtile-mimeapps.list (fora do home-manager, que gerencia o
# mimeapps.list principal como symlink read-only). Se um dia quisermos isso
# declarativo, o lugar é xdg.mimeApps no home-manager do usuário.
{ pkgsElectron, ... }:

let
  granola = pkgsElectron.callPackage ../pkgs/granola.nix { };
in
{
  environment.systemPackages = [ granola ];
}
