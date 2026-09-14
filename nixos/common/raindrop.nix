# Raindrop.io (AppImage oficial embrulhado com appimageTools). Ver
# nixos/pkgs/raindrop.nix.
#
# Handler do rnio:// (callback de login): o .desktop que vem no AppImage já
# declara o MimeType, então o pacote registra o app como candidato. O default
# do usuário fica em ~/.config/qtile-mimeapps.list (fora do home-manager, que
# gerencia o mimeapps.list principal como symlink read-only) — mesma abordagem
# do granola.nix.
{ pkgs, ... }:

{
  environment.systemPackages = [ (pkgs.callPackage ../pkgs/raindrop.nix { }) ];
}
