# AGENTS.md — guia para agentes nesta config NixOS

Contexto operacional para trabalhar em `nixos-config/`. Leia junto com o [README.md](./README.md) (organização dos módulos). Estas regras têm precedência sobre defaults genéricos.

## Modelo mental

- **Um único `flake.nix` multi-host.** `nixosConfigurations.{navi,fi}`. Cada host = `hosts/<host>/configuration.nix`, que importa os `common/*` + (opcionalmente) `modules/*` + seu `hardware-configuration.nix`.
- **Host selecionado pelo nome do atributo**; hostname é só o default de `--flake .` sem `#host`.
- **Avaliação pura — NÃO use `--impure`.** O hardware vem de `hosts/<host>/hardware-configuration.nix` versionado. Se algo exigir `--impure`, é bug: corrija o caminho absoluto em vez de adicionar a flag.
- **`common/` é compartilhado por TODOS os hosts.** Qualquer edição ali afeta navi e fi. Mudança específica de um host vai em `hosts/<host>/` ou num `modules/*` importado só por ele.

## Onde mexer (ver tabela no README)

`base.nix` = boot/rede/SSH/Avahi/locale/usuários/pacotes de sistema · `desktop.nix` = X11/GNOME/temas/Zsh/apps · `development.nix` = Docker/linguagens/cloud/IDEs · `services.nix` = daemons (syncthing/keyd/qtile/bluetooth) · `modules/{nvidia,gaming}.nix` = só fi.

Nunca edite `hardware-configuration.nix` à mão nem `flake.lock`.

## Fluxo de trabalho obrigatório

1. **Build antes de qualquer switch:** `nixos-rebuild build --flake .#<host>` (sem sudo). Só faça `switch` depois do build limpo.
2. **Nunca `switch` para um host que não é a máquina atual.** Para o outro host, só `build`.
3. **Prefira `test` a `switch`** quando estiver iterando: `sudo nixos-rebuild test --flake .` ativa sem gravar no bootloader.

## Verificação de equivalência (padrão-ouro)

Ao refatorar/modularizar, **prove que a nova config reproduz a antiga** antes de aplicar — foi assim que a migração do `navi` foi validada:

```bash
# NOVA config
nixos-rebuild build --flake .#navi && mv result result-new

# Config de REFERÊNCIA (ex.: revisão anterior) via worktree, mesmo flake.lock:
git worktree add /tmp/ref <rev> && \
  nixos-rebuild build --flake /tmp/ref/nixos-config#navi && mv result result-old

# Diferença de pacotes:
nix store diff-closures ./result-old ./result-new

# Diferença de config (etc/units/activation): normalize os hashes do store e
# compare — o que sobrar depois de normalizar é diferença REAL, não churn:
#   sed -E 's#/nix/store/[a-z0-9]{32}-#H-#g'  em cada arquivo de $sys/etc antes de diff.
```

Um `switch` bem-sucedido constrói o **mesmo store path** do build que você validou — confira o hash no output do `switch` contra o do build.

## Convenções

- **Commits:** **NUNCA** adicione `Co-Authored-By: Claude` (nem qualquer co-autoria de IA). Commits saem só em nome do usuário.
- **Idioma:** comentários e docs em português (segue o estilo do repo).
- **Reboot:** só é necessário se o `diff-closures` mostrar mudança de kernel/initrd/bootloader. Adição de pacotes de userland ativa ao vivo, sem reboot.
- **Aplicar mudanças:** ações que alteram o sistema (`switch`), removem arquivos ou commitam devem ser confirmadas com o usuário antes.

## Estado atual (2026-07-11)

- **navi:** migrado para modular e ativo. Equivalência com o sistema anterior verificada (diff de closures vazio exceto por utilitários extras aprovados).
- **fi:** PENDENTE — `hardware-configuration.nix` é placeholder; `modules/nvidia.nix` e `modules/gaming.nix` comentados em `hosts/fi/configuration.nix`. Ativar ao instalar na máquina real.
- Docs `FASE*.md`/`CUSTOM-PACKAGES.md` descrevem o monolito original (histórico); a estrutura viva é a modular.
