# Raindrop.io — bookmark manager. Não tem pacote nativo Linux, mas o repo
# oficial publica um AppImage nos releases do GitHub. appimageTools embrulha o
# AppImage num FHS; o app já traz o próprio Electron, então nada de rebuild.
#
# ATUALIZAR: bump de version + hash a partir de
# https://github.com/raindropio/desktop/releases
#   nix hash convert --hash-algo sha256 $(nix-prefetch-url <url-do-AppImage>)
{ lib, appimageTools, fetchurl }:

let
  pname = "raindrop";
  version = "5.7.9";

  src = fetchurl {
    url = "https://github.com/raindropio/desktop/releases/download/v${version}/Raindrop-x86_64.AppImage";
    hash = "sha256-wQJMFMQjkeMhOt2qE41cPKjjMgPNdpqQ3YGKtNWgvSk=";
  };

  # Conteúdo extraído para pegar o .desktop (já declara o handler rnio://) e os
  # ícones hicolor que o AppImage embute.
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/raindrop.desktop -t $out/share/applications
    # Exec do AppImage aponta pra AppRun; troca pelo binário embrulhado.
    substituteInPlace $out/share/applications/raindrop.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=raindrop'
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Raindrop.io — all-in-one bookmark manager (AppImage oficial)";
    homepage = "https://raindrop.io";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "raindrop";
  };
}
