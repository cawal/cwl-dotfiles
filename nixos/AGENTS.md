# AGENTS.md — guia para agentes nesta config NixOS

Contexto operacional para trabalhar nesta config (dir `nixos/`). O `flake.nix` fica na **raiz do repo** (`~/git/cwl-dotfiles`), então os comandos `nixos-rebuild --flake .#<host>` rodam de lá. Leia junto com o [README.md](./README.md) (organização dos módulos). Estas regras têm precedência sobre defaults genéricos.

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
  nixos-rebuild build --flake /tmp/ref#navi && mv result result-old

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

## Instalar/reinstalar um host com disko (LVM-on-LUKS, /home separado)

Layout padrão em `nixos/common/disko-lvm-luks.nix`; cada host tem `hosts/<host>/disko.nix` com o `device`. Ver README → “Esquema de disco”.

**Regra de sequenciamento (crítica):** o `disko.nix` gera `fileSystems`/`swapDevices`/`boot.initrd.luks` apontando para `/dev/mapper/pool-*`, que **só existem depois** do disko rodar. O wiring do disko (`disko.nixosModules.disko` + `./nixos/hosts/<host>/disko.nix`) **já está na `master`** para os dois hosts — as branches `navi-disko`/`fi-disko` foram mergeadas. Isso é **seguro para `nixos-rebuild switch` nas máquinas já instaladas**, porque o pool `/dev/mapper/pool-*` existe e a config só declara o que já está no disco. O **perigo** existe apenas num disco **sem o pool ainda** (instalação nova): aí **não** use `switch` — use `nixos-install` (runbook abaixo).

**Runbook (no live USB, tudo já committado+push antes):**
```bash
# 1. obter o repo — qualquer uma:
#    (a) git clone do GitHub (precisa rede), OU
#    (b) segundo pendrive ext4 com o repo já clonado (feito antes; branches locais), OU
#    (c) montar a partição LUKS atual e copiar o repo ANTES de destruir o disco
#    ex. (b): sudo mount /dev/sdX1 /mnt/pen && cd /mnt/pen/cwl-dotfiles
#             git config --global --add safe.directory "$PWD"   # evita 'dubious ownership'
# 2. cd repo   # a master já tem o wiring do disko + layout novo (flake na raiz)
# 3. sudo nix run --extra-experimental-features "flakes nix-command" github:nix-community/disko/latest -- --mode destroy,format,mount ./nixos/hosts/<host>/disko.nix
# 4. sudo nixos-generate-config --no-filesystems --root /mnt   # atualiza hardware-configuration.nix
# 5. sudo nixos-install --flake .#<host>
# 6. reboot (pede UMA senha LUKS); validar. (As branches *-disko já estão na master.)
```

Validar o disko **sem tocar no disco**: `nixos-rebuild build --flake .#<host>` (da raiz) avalia o `disko.devices` e constrói o toplevel (só build, não monta nada).

## Estado atual (2026-07-28)

- **Reestruturação (2026-07-28):** o `flake.nix` foi movido de `nixos-config/` para a **raiz do repo**; os módulos ficam em `nixos/`, a config home-manager em `nixos/home/`, e estes docs em `nixos/` + `nixos/docs/`. Comandos rodam da raiz (`--flake .#<host>`). O sistema gerado é idêntico (drvPath inalterado). Home-manager ativo em navi e fi (gerencia o yazi via `programs.yazi`).

- **navi:** migrado para modular e ativo. Equivalência com o sistema anterior verificada (diff de closures vazio exceto por utilitários extras aprovados).
- **fi:** instalado e ativo (é esta máquina). Importa `modules/nvidia.nix` (RTX 4060, PRIME offload) + `modules/gaming.nix`, com `boot.resumeDevice` p/ hibernação. `hosts/fi/disko.nix` define NVMe `/dev/nvme0n1` (swap 24G, root 100G, LV Docker 250G, /home no resto) — os `fileSystems` vêm do disko; o `hardware-configuration.nix` é o scan `--no-filesystems` (por isso não lista `fileSystems`). Wiring do disko na `master` (branch `fi-disko` mergeada). **Guia: [INSTALL-FI.md](./docs/INSTALL-FI.md).**
- **Limpeza automática (todos os hosts):** `virtualisation.docker.autoPrune` (semanal, `--all`) em `common/development.nix`; `nix.gc` (semanal, 30d) + `nix.optimise` em `common/base.nix`.
- **Isolamento do Docker:** o helper `disko-lvm-luks.nix` aceita `dockerSize` — quando setado, cria LV próprio p/ `/var/lib/docker` (usado no fi; navi não usa, Docker fica no root).
- Docs `FASE*.md`/`CUSTOM-PACKAGES.md` descrevem o monolito original (histórico); a estrutura viva é a modular.
