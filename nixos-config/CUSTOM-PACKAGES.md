# Pacotes Personalizados no NixOS

## Problema

Alguns pacotes não estão disponíveis no repositório oficial nixpkgs, como o `greenclip`.

## Solução: Overlays no Flake

Criamos um overlay customizado no `flake.nix` para adicionar pacotes que não existem no nixpkgs.

---

## Como Funciona

### 1. Definir o Overlay no flake.nix

```nix
customOverlay = final: prev: {
  greenclip = final.haskellPackages.callCabal2nix "greenclip" (final.fetchFromGitHub {
    owner = "erebe";
    repo = "greenclip";
    rev = "v4.2";
    sha256 = final.lib.fakeSha256;  # Placeholder - será atualizado
  }) {};
};
```

### 2. Aplicar o Overlay

```nix
nixosConfigurations.navi = nixpkgs.lib.nixosSystem {
  modules = [ 
    ./nixos/configuration.nix
    { nixpkgs.overlays = [ customOverlay ]; }
  ];
};
```

### 3. Usar o Pacote

No `configuration.nix`, simplesmente adicione:

```nix
environment.systemPackages = with pkgs; [
  greenclip  # Agora disponível via overlay
];
```

---

## Obtendo o Hash Correto

### Método 1: Deixar o Nix falhar e mostrar o hash

1. Use `final.lib.fakeSha256` como placeholder
2. Execute `sudo nixos-rebuild test --flake . --impure`
3. O erro mostrará o hash correto:
   ```
   error: hash mismatch in fixed-output derivation
   got:    sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=
   ```
4. Copie o hash `got:` e atualize o flake.nix

### Método 2: Usar nix-prefetch-github

```bash
nix-shell -p nix-prefetch-github
nix-prefetch-github erebe greenclip --rev v4.2
```

Saída:
```json
{
  "owner": "erebe",
  "repo": "greenclip",
  "rev": "v4.2",
  "sha256": "hash-aqui"
}
```

---

## Próximos Passos

Após o rebuild falhar na primeira vez:

1. Copiar o hash correto do erro
2. Atualizar `flake.nix`:
   ```nix
   sha256 = "sha256-HASH-CORRETO-AQUI=";
   ```
3. Executar novamente: `sudo nixos-rebuild test --flake . --impure`

---

## Outros Pacotes Haskell

Greenclip é um pacote Haskell, por isso usamos `haskellPackages.callCabal2nix`.

Para outros tipos de pacotes:

### Go
```nix
meu-pacote-go = final.buildGoModule {
  pname = "meu-pacote";
  version = "1.0.0";
  src = final.fetchFromGitHub { ... };
  vendorHash = final.lib.fakeSha256;  # Mesmo processo
};
```

### Rust
```nix
meu-pacote-rust = final.rustPlatform.buildRustPackage {
  pname = "meu-pacote";
  version = "1.0.0";
  src = final.fetchFromGitHub { ... };
  cargoHash = final.lib.fakeSha256;
};
```

### Python
```nix
meu-pacote-python = final.python3Packages.buildPythonPackage {
  pname = "meu-pacote";
  version = "1.0.0";
  src = final.fetchFromGitHub { ... };
  # ...
};
```

### Binário pré-compilado
```nix
meu-app = final.stdenv.mkDerivation {
  pname = "meu-app";
  version = "1.0.0";
  src = final.fetchurl {
    url = "https://exemplo.com/app.tar.gz";
    sha256 = final.lib.fakeSha256;
  };
  installPhase = ''
    mkdir -p $out/bin
    cp app $out/bin/
  '';
};
```

---

## Exemplo Completo: Adicionar outro pacote

Vamos adicionar o `raindrop` (se não existir):

```nix
customOverlay = final: prev: {
  greenclip = ...;  # já existe
  
  raindrop = final.buildNpmPackage {
    pname = "raindrop";
    version = "1.0.0";
    src = final.fetchFromGitHub {
      owner = "owner-nome";
      repo = "raindrop";
      rev = "v1.0.0";
      sha256 = final.lib.fakeSha256;
    };
    npmDepsHash = final.lib.fakeSha256;
  };
};
```

---

## Troubleshooting

### Erro: "attribute 'greenclip' missing"

**Causa:** O overlay não foi aplicado corretamente.

**Solução:** Verificar que o overlay está em `nixpkgs.overlays`:

```nix
modules = [ 
  ./nixos/configuration.nix
  { nixpkgs.overlays = [ customOverlay ]; }  # ← importante
];
```

### Erro: Build falha com dependências faltando

**Causa:** Dependências do sistema não declaradas.

**Solução:** Adicionar `buildInputs`:

```nix
greenclip = final.haskellPackages.callCabal2nix "greenclip" ... {
  buildInputs = with final; [ xorg.libX11 xorg.libXrandr ];
};
```

### Erro: Hash mismatch após atualizar versão

**Causa:** Hash antigo no flake.

**Solução:** Usar `final.lib.fakeSha256` novamente e pegar o novo hash.

---

## Referências

- [NixOS Wiki - Overlays](https://nixos.wiki/wiki/Overlays)
- [Nix Pills - Overlays](https://nixos.org/guides/nix-pills/nixpkgs-overriding-packages.html)
- [callCabal2nix docs](https://haskell4nix.readthedocs.io/nixpkgs-users-guide.html#how-to-build-a-haskell-project-using-cabal2nix)
