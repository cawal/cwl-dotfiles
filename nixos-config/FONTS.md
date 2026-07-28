# Fontes no NixOS

As fontes do sistema são declaradas em `nixos/common/fonts.nix`, importado por
`nixos/common/desktop.nix` (logo, valem para todos os hosts com desktop).
**É nesse arquivo que você mexe** para adicionar/remover fontes.

Depois de qualquer mudança:

```bash
sudo nixos-rebuild switch --flake .#fi   # ou .#navi
```

O fontconfig varre todo pacote listado em `fonts.packages` procurando arquivos
em `share/fonts/` — então basta o pacote depositar os `.ttf`/`.otf` lá.

---

## Fontes que já existem no nixpkgs

O caso mais comum. Só adicionar o pacote em `fonts.packages`.

### Nerd Fonts

A partir do NixOS 24.11 cada Nerd Font é um pacote no namespace
`nerd-fonts.<nome>` (o antigo `nerdfonts` monolítico com `override` foi
**removido** — tutoriais que usam isso estão desatualizados).

```nix
fonts.packages = with pkgs; [
  nerd-fonts.hack
  nerd-fonts.fira-code
  nerd-fonts.monoid
];
```

Listar todos os nomes disponíveis:

```bash
nix eval --raw --impure --expr \
  'builtins.concatStringsSep "\n" (builtins.attrNames (import <nixpkgs> {}).nerd-fonts)'
```

### Google Fonts

`google-fonts` traz a **coleção inteira (~2 GB)**. Para poucas famílias,
restrinja com `override` (os nomes são os das famílias como aparecem no
fonts.google.com):

```nix
fonts.packages = with pkgs; [
  (google-fonts.override { fonts = [ "Inter" "Roboto" "Fira Sans" ]; })
];
```

### Outras (Noto, etc.)

```nix
fonts.packages = with pkgs; [
  noto-fonts                # Noto Sans/Serif
  noto-fonts-color-emoji    # emojis coloridos
];
```

---

## Fonte custom (arquivo local ou URL)

Quando a fonte **não está no nixpkgs** — feita por você, ou baixada de algum
site. A ideia é sempre a mesma: uma mini-derivation que joga os arquivos em
`$out/share/fonts/{truetype,opentype}/` e entra em `fonts.packages`.

### Arquivo local

Coloque o arquivo no repo (ex.: `nixos/common/fonts-custom/MinhaFonte.ttf`) e:

```nix
{ config, pkgs, ... }:
let
  minhaFonte = pkgs.runCommandNoCC "minha-fonte" { } ''
    install -Dm644 ${./fonts-custom/MinhaFonte.ttf} \
      $out/share/fonts/truetype/MinhaFonte.ttf
  '';
in {
  fonts.packages = with pkgs; [
    minhaFonte
    # ... demais fontes
  ];
}
```

> ⚠️ **Flake só enxerga arquivos rastreados pelo git.** Após copiar o `.ttf`
> para o repo, rode `git add nixos/common/fonts-custom/` — senão o build falha
> com "path ... not tracked".

### URL de um arquivo solto

```nix
minhaFonte = pkgs.runCommandNoCC "minha-fonte" { } ''
  install -Dm644 ${pkgs.fetchurl {
    url  = "https://exemplo.com/MinhaFonte.ttf";
    hash = "sha256-AAAA...";   # ver abaixo como obter
  }} $out/share/fonts/truetype/MinhaFonte.ttf
'';
```

### URL de um `.zip` (várias variantes/pesos)

```nix
minhaFonte = pkgs.stdenvNoCC.mkDerivation {
  pname = "minha-fonte";
  version = "1.0";
  src = pkgs.fetchzip {
    url  = "https://exemplo.com/minha-fonte.zip";
    hash = "sha256-BBBB...";
    stripRoot = false;   # se o zip não tiver uma pasta-raiz única
  };
  installPhase = ''
    runHook preInstall
    install -Dm644 *.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';
};
```

### Obter o hash de uma URL

```bash
nix-prefetch-url <url> | xargs nix hash to-sri --type sha256
```

Ou ponha `hash = pkgs.lib.fakeHash;`, rode o build e copie o hash `got:` do erro.

---

## Definir a fonte padrão do sistema

Em `fontconfig.defaultFonts`, referencie o **nome interno da família** (não o do
arquivo). Descubra o nome com:

```bash
fc-scan --format '%{family}\n' MinhaFonte.ttf
```

```nix
fonts.fontconfig.defaultFonts = {
  monospace = [ "Hack Nerd Font" ];
  sansSerif = [ "Noto Sans" ];
  serif     = [ "Noto Serif" ];
  emoji     = [ "Noto Color Emoji" ];
};
```

Apps que definem a própria fonte (kitty, rofi, etc.) ignoram esses padrões —
`defaultFonts` é só o fallback quando nada é especificado.

---

## Migração de fontes instaladas à mão

Fontes copiadas manualmente para `~/.local/share/fonts` ou `~/.fonts` continuam
funcionando, mas ficam **fora do controle declarativo** e podem conflitar com
versões do sistema. O ideal é declará-las no `fonts.nix` (via nixpkgs ou como
custom) e remover as cópias manuais. Um backup em `~/Fonts` guarda os originais
caso precise reinstalar algo pontualmente.
