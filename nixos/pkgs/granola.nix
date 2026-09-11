# Granola — "AI Notepad for meetings". Só tem build oficial para macOS/Windows,
# mas é um app Electron: o .dmg do macOS carrega todo o JS do app, que roda em
# qualquer lugar. Esta derivação extrai esse payload, troca o runtime pelo
# Electron do nixpkgs e corrige o que quebra no Linux. Sem Wine/VM.
#
# Baseada em https://github.com/tirtha4/Granola-for-Linux (script imperativo),
# reescrita como derivação pura.
#
# ATUALIZAR: a URL download-latest redireciona para uma URL versionada do
# CloudFront. Para bumpar:
#   1) curl -sI https://api.granola.ai/v1/download-latest | grep -i location
#      -> pega a nova versão e a URL do .dmg
#   2) version = a nova versão
#   3) dmgHash = nix hash convert --hash-algo sha256 \
#         $(nix-prefetch-url <url-do-dmg>)   (ou deixe vazio e copie do erro)
#   4) confira bs3Version: node -p da versão de better-sqlite3-multiple-ciphers
#      dentro do app.asar.unpacked, e atualize bs3Hash se mudar.
{ lib
, stdenv
, fetchurl
, _7zz
, nodejs
, python3
, node-gyp
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, electron_44
}:

let
  electron = electron_44;

  version = "7.559.2";
  bs3Version = "12.9.0";

  dmg = fetchurl {
    url = "https://dr2v7l5emb758.cloudfront.net/${version}/Granola-${version}-mac-universal.dmg";
    hash = "sha256-dLScRxiztYm8Yw+QKzVUOTp+0eHUC1MlQIgVytRcijg=";
  };

  # O fork better-sqlite3-multiple-ciphers que a Granola embute é patchado (tem
  # updateHook(), que nenhum build público traz), mas o binding.gyp não vem no
  # bundle. Pegamos só o binding.gyp do release público correspondente no npm.
  bs3Tgz = fetchurl {
    url = "https://registry.npmjs.org/better-sqlite3-multiple-ciphers/-/better-sqlite3-multiple-ciphers-${bs3Version}.tgz";
    hash = "sha256-rYzrLP5ofgwQZUf90oHw0gtAaIIA0E9AuxY6/R8QJgk=";
  };
in
stdenv.mkDerivation {
  pname = "granola";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ _7zz nodejs python3 node-gyp makeWrapper copyDesktopItems autoPatchelfHook ];

  # Os .node prebuilt que vêm no bundle (ex.: electron-click-drag-plugin) são
  # binários dinâmicos sem RPATH pro nix store; sem isto falham com
  # "libstdc++.so.6: cannot open shared object file" no Electron nativo.
  # autoPatchelfHook corrige o RPATH dos ELF Linux; os .node mac/win (não-ELF)
  # são ignorados.
  buildInputs = [ stdenv.cc.cc.lib ];

  desktopItems = [
    (makeDesktopItem {
      name = "granola";
      desktopName = "Granola";
      comment = "AI Notepad for meetings";
      exec = "granola %U";
      icon = "granola";
      terminal = false;
      categories = [ "Office" "Utility" ];
      startupWMClass = "granola";
      # Handler do granola:// (callback de login OAuth).
      mimeTypes = [ "x-scheme-handler/granola" ];
    })
  ];

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"

    RES="Granola/Granola.app/Contents/Resources"

    # 1) extrai o payload do app do .dmg (compressão LZFSE -> 7zz moderno)
    7zz x ${dmg} "$RES/app.asar" "$RES/app.asar.unpacked" "$RES/icons" -odmg -y >/dev/null
    RESDIR="dmg/$RES"

    # 2) patch da string de plataforma: api.granola.ai devolve 500 para
    #    platform=linux (inclusive na URL de login). O app mapeia darwin->macOS,
    #    win32->Windows e passa o resto verbatim; reescrevemos esse fallback para
    #    Linux reportar Windows. Byte-for-byte (padding com espaços) por causa do
    #    header de offsets do .asar.
    python3 - "$RESDIR/app.asar" <<'PYEOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); data = p.read_bytes(); total = 0
for pat in (b'?`Windows`:window.electron.platform', b'?`Windows`:process.platform'):
    rep = b'?`Windows`:`Windows`'.ljust(len(pat))
    total += data.count(pat)
    data = data.replace(pat, rep)
if total == 0:
    sys.exit("no platform fallback found (bundler output may have changed)")
p.write_bytes(data)
print(f"rewrote {total} platform fallback(s)")
PYEOF

    # 3) neutraliza o electron-click-drag-plugin. Ele traz .node prebuilt
    #    (macOS/Windows/Linux) sem fonte e sem linkar numa ABI específica; o
    #    binário linux-x64 SEGFAULTA no dlopen, antes de qualquer janela. O
    #    bundle do main-process exige esse módulo incondicionalmente no startup
    #    e não trata falha de carga, então um .node quebrado derruba o app todo.
    #    Trocamos o loader por um stub no-op (Proxy): todo acesso/chamada vira
    #    função vazia. (Correção idêntica à do howird/granola-flake.)
    cp ${./granola-clickdrag-stub.js} "$RESDIR/app.asar.unpacked/node_modules/electron-click-drag-plugin/index.js"

    # 4) recompila better-sqlite3-multiple-ciphers a partir do fonte (que vem no
    #    app.asar.unpacked) contra os headers do Electron 44.
    BS3="$RESDIR/app.asar.unpacked/node_modules/better-sqlite3-multiple-ciphers"
    tar xzf ${bs3Tgz} -C .
    cp package/binding.gyp "$BS3/"

    # Chamamos node-gyp.js DIRETO (não o wrapper do nixpkgs). O wrapper força
    # npm_config_nodedir=<nodejs>, o que compilaria contra a ABI errada e contra
    # o sqlite3.h stock que o Node 22+ embute — isso esconde as funções de codec
    # (sqlite3_key/rekey) do fork e o build falha. Os headers do Electron 44 não
    # têm sqlite3.h, então o amalgamation com codec do fork vence, e a ABI
    # (NODE_MODULE_VERSION do embedder) casa com o electron_44 que empacotamos.
    ( cd "$BS3" && env -u npm_config_nodedir \
        node ${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js rebuild --release \
        --runtime=electron --target=${electron.version} --arch=x64 \
        --nodedir=${electron.headers} )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    RESDIR="dmg/Granola/Granola.app/Contents/Resources"
    APP="$out/libexec/granola/resources"
    mkdir -p "$APP"
    cp -r "$RESDIR/app.asar" "$RESDIR/app.asar.unpacked" "$RESDIR/icons" "$APP/"

    install -Dm644 "$RESDIR/icons/mac-icon.png" "$out/share/pixmaps/granola.png"

    makeWrapper ${electron}/bin/electron "$out/bin/granola" \
      --add-flags "$APP/app.asar" \
      --add-flags "--ozone-platform-hint=auto"

    runHook postInstall
  '';

  # Falha o build se o módulo nativo não carregar na ABI do Electron 44 (pega
  # regressões como o node-gyp não recompilar de fato). Roda sem display.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    ELECTRON_RUN_AS_NODE=1 \
      NODE_PATH="$out/libexec/granola/resources/app.asar/node_modules" \
      ${electron}/bin/electron -e "
        const Database = require('$out/libexec/granola/resources/app.asar.unpacked/node_modules/better-sqlite3-multiple-ciphers/lib/index.js');
        const db = new Database('$TMPDIR/smoke.db');
        db.pragma(\"cipher='sqlcipher'\");
        db.pragma(\"key='smoketest'\");
        db.exec('CREATE TABLE t(a)');
        let fired = false;
        db.updateHook(() => { fired = true; });
        db.prepare('INSERT INTO t VALUES (1)').run();
        if (db.prepare('SELECT count(*) c FROM t').get().c !== 1) throw new Error('insert failed');
        if (!fired) throw new Error('updateHook did not fire');
        db.close();
      "

    runHook postInstallCheck
  '';

  meta = {
    description = "Granola AI Notepad (build macOS reempacotado para Linux)";
    homepage = "https://www.granola.ai";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "granola";
  };
}
