# ntn — Notion CLI (https://developers.notion.com/cli)
#
# Não existe no nixpkgs. O pacote npm `ntn` é só um wrapper: o binário real é
# um executável Bun estático (static-PIE, sem loader dinâmico nem libs externas)
# que já vem EMBUTIDO no tarball do npm, em dist/<os>-<arch>/. Por isso não
# usamos node2nix/buildNpmPackage (dariam voltas para, no fim, copiar o binário):
# baixamos o tarball versionado e instalamos o binário direto. Como é estático,
# não precisa de autoPatchelfHook.
#
# Atualizar versão:
#   1. troque `version` abaixo
#   2. pegue o novo hash:
#        nix-prefetch-url https://registry.npmjs.org/ntn/-/ntn-<versão>.tgz \
#          | xargs nix hash to-sri --type sha256
#   3. cole em `hash`
{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ntn";
  version = "0.21.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/ntn/-/ntn-${finalAttrs.version}.tgz";
    hash = "sha256-60VVf4GRV/FjJrK5L1OT4zM3Y8f7NJi6h7FzcTry7Sk=";
  };

  # O tarball do npm extrai para package/
  sourceRoot = "package";

  # Binário pronto: só instalar. Ambos os hosts (navi/fi) são x86_64-linux.
  # Para adicionar aarch64, mapeie dist/ntn-linux-arm64/ntn conforme stdenv.
  installPhase = ''
    runHook preInstall
    install -Dm755 dist/ntn-linux-x64/ntn $out/bin/ntn
    runHook postInstall
  '';

  meta = {
    description = "Notion CLI (ntn) — ferramenta de linha de comando do Notion";
    homepage = "https://developers.notion.com/cli";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ntn";
  };
})
