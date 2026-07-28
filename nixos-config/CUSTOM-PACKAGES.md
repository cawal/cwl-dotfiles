# Pacotes Personalizados no NixOS

## Quando usar isto

Só quando um programa **não existe no nixpkgs**. Antes de empacotar qualquer
coisa, verifique se já não está lá:

```bash
nix search nixpkgs <nome>
```

> **Nota histórica:** este documento já descreveu o `greenclip` como exemplo de
> pacote via overlay. Isso estava **errado** — o greenclip vem direto do
> nixpkgs, habilitado por `services.greenclip.enable = true;` em
> `nixos/common/services.nix`. Nenhum overlay foi necessário para ele. O
> exemplo real e funcional de pacote próprio é o `ntn` (Notion CLI), descrito
> abaixo.

---

## Estrutura real

O overlay de pacotes próprios fica em `nixos/overlays/`:

```
nixos/overlays/
  default.nix   # overlay agregador: final: prev: { ntn = ...; }
  ntn.nix       # uma derivation por arquivo (assinatura callPackage)
```

Ele é aplicado em `nixos/common/base.nix`, que **todos os hosts importam**:

```nix
# nixos/common/base.nix
nixpkgs.overlays = [ (import ../overlays) ];
```

Com isso, cada pacote definido no overlay vira `pkgs.<nome>` e pode ser usado
em qualquer lugar como se fosse do nixpkgs:

```nix
environment.systemPackages = with pkgs; [
  ntn   # Notion CLI, vindo do overlay
];
```

---

## Adicionar uma nova ferramenta

1. Crie `nixos/overlays/<nome>.nix` com assinatura `callPackage`
   (`{ lib, stdenvNoCC, fetchurl, ... }:`).
2. Registre em `nixos/overlays/default.nix`:
   ```nix
   final: prev: {
     ntn   = final.callPackage ./ntn.nix { };
     <nome> = final.callPackage ./<nome>.nix { };
   }
   ```
3. Use `pkgs.<nome>` em `systemPackages`.
4. `sudo nixos-rebuild switch --flake .#<host>`.

---

## O caso comum: binário pré-compilado (recomendado)

A maioria das CLIs modernas (Bun, Go, Rust, ou "npm" que na verdade só
embrulha um binário) distribui um **executável pronto**. Nesses casos,
`node2nix`/`buildNpmPackage` são o caminho errado — dão voltas para, no fim, só
copiar o binário. Pegue-o direto com `fetchurl` e instale.

Exemplo real: **`ntn`** (`nixos/overlays/ntn.nix`). O pacote npm `ntn` é só um
wrapper; o binário real é um executável Bun **estático** (static-PIE, sem loader
dinâmico nem libs externas) já embutido no tarball do npm em `dist/`. Por ser
estático, nem precisa de `autoPatchelfHook`:

```nix
{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ntn";
  version = "0.21.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/ntn/-/ntn-${finalAttrs.version}.tgz";
    hash = "sha256-60VVf4GRV/FjJrK5L1OT4zM3Y8f7NJi6h7FzcTry7Sk=";
  };

  sourceRoot = "package";   # o tarball do npm extrai para package/

  installPhase = ''
    runHook preInstall
    install -Dm755 dist/ntn-linux-x64/ntn $out/bin/ntn
    runHook postInstall
  '';

  meta = {
    description = "Notion CLI (ntn)";
    homepage = "https://developers.notion.com/cli";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ntn";
  };
})
```

### Se o binário for dinâmico (não estático)

Num NixOS ele falharia por falta do loader/libs. Aí use `autoPatchelfHook`:

```nix
{ lib, stdenv, fetchurl, autoPatchelfHook, stdenvNoCC }:

stdenv.mkDerivation {
  # ...
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib /* zlib, openssl, etc conforme `ldd` pedir */ ];
  # ...
}
```

---

## Pinar / atualizar versão

Tudo é pinado por `version` + `hash` no arquivo da derivation. Para atualizar:

1. Troque `version`.
2. Recalcule o hash SRI:
   ```bash
   nix-prefetch-url https://registry.npmjs.org/ntn/-/ntn-<versão>.tgz \
     | xargs nix hash to-sri --type sha256
   ```
3. Cole em `hash` e faça `nixos-rebuild`.

Truque alternativo: ponha `hash = lib.fakeHash;`, rode o build e copie o hash
`got:` do erro.

---

## Empacotar a partir do código-fonte (menos comum)

Quando NÃO há binário pronto e você precisa compilar. O hash da build
(`vendorHash`/`cargoHash`/`npmDepsHash`) começa como `lib.fakeHash` e é
corrigido a partir do erro do primeiro build.

### Go
```nix
{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule {
  pname = "meu-pacote"; version = "1.0.0";
  src = fetchFromGitHub { owner = "..."; repo = "..."; rev = "v1.0.0"; hash = lib.fakeHash; };
  vendorHash = lib.fakeHash;
}
```

### Rust
```nix
{ rustPlatform, fetchFromGitHub, lib }:
rustPlatform.buildRustPackage {
  pname = "meu-pacote"; version = "1.0.0";
  src = fetchFromGitHub { owner = "..."; repo = "..."; rev = "v1.0.0"; hash = lib.fakeHash; };
  cargoHash = lib.fakeHash;
}
```

### Node (JS de verdade, com deps)
Só quando o pacote é realmente JavaScript com dependências (não um wrapper de
binário). `buildNpmPackage` precisa do repositório com `package-lock.json`:
```nix
{ buildNpmPackage, fetchFromGitHub, lib }:
buildNpmPackage {
  pname = "meu-pacote"; version = "1.0.0";
  src = fetchFromGitHub { owner = "..."; repo = "..."; rev = "v1.0.0"; hash = lib.fakeHash; };
  npmDepsHash = lib.fakeHash;
}
```

Para instalar **várias** CLIs npm de uma lista declarativa, considere o
`node2nix` (gera expressões a partir de um `node-packages.json`) — mas ele tem
um passo de codegen manual e só compensa se o pacote for JS puro.

---

## Troubleshooting

### `error: attribute 'ntn' missing`
O overlay não está sendo aplicado. Confira se
`nixpkgs.overlays = [ (import ../overlays) ];` está em `base.nix` e se o host
importa `base.nix`.

### `hash mismatch`
O `hash` da derivation não bate com o que foi baixado. Copie o hash `got:` do
erro (ver seção "Pinar / atualizar versão").

### Binário não roda (`No such file or directory`)
O binário é dinâmico e precisa de `autoPatchelfHook` (ver acima), ou faltou uma
lib em `buildInputs` — rode `ldd <binário>` para descobrir quais.
