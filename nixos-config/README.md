# CWL NixOS Configuration

Configuração NixOS **declarativa e multi-host**, compartilhada entre máquinas via um único `flake.nix`. Hoje há dois hosts:

| Host   | Máquina                     | Particularidades                          |
|--------|-----------------------------|-------------------------------------------|
| `navi` | laptop (em uso)             | sem GPU dedicada                          |
| `fi`   | laptop (a instalar)         | NVIDIA RTX 4060 + gaming; Docker pesado (LV próprio) |

Ambos rodam **NixOS 26.05**, desktop **Qtile**, shell **Zsh + Oh My Zsh**, com SSH, Syncthing e mDNS (`<host>.local`).

---

## Como aplicar

O host é escolhido pelo **nome do atributo** em `nixosConfigurations` (`navi`/`fi`). Rodando sem `#host`, o `nixos-rebuild` usa o **hostname** da máquina como default — então em cada máquina basta:

```bash
cd ~/git/cwl-dotfiles/nixos-config

# Testar (ativa até o próximo boot, não persiste no bootloader)
sudo nixos-rebuild test   --flake .

# Aplicar permanentemente
sudo nixos-rebuild switch --flake .

# Rollback se algo quebrar
sudo nixos-rebuild --rollback switch
```

> **Sem `--impure`.** O hardware é lido de `hosts/<host>/hardware-configuration.nix` (versionado no repo), não de `/etc/nixos`. A avaliação é pura.

Para construir/aplicar um host explicitamente (ex.: gerar a config do `fi` a partir do `navi`): use `--flake .#fi` (só `build`, nunca `switch` para outro host).

---

## Organização da config

```
nixos-config/
├── flake.nix                 # Entrada: define nixosConfigurations.{navi,fi}
├── flake.lock                # Pin do nixpkgs (não editar à mão)
└── nixos/
    ├── common/               # ── COMPARTILHADO por TODOS os hosts ──
    │   ├── base.nix          # boot, rede (NetworkManager), SSH, Avahi, locale,
    │   │                     #   usuários, nix-ld, Firefox, pacotes de sistema base
    │   ├── desktop.nix       # X11/GNOME, Picom, temas GTK/Qt, Zsh+Oh My Zsh,
    │   │                     #   apps de desktop (rofi, nautilus, obsidian, slack…)
    │   ├── development.nix    # Docker, AppImage, Node/Python/Java, cloud
    │   │                     #   (gcloud/kubectl/helm/terraform), IDEs, DB, diagramas
    │   └── services.nix       # Pipewire, impressão, Bluetooth, Greenclip,
    │                         #   Syncthing (base), keyd, Qtile (windowManager)
    ├── modules/              # ── OPCIONAIS, importados por host que precisa ──
    │   ├── nvidia.nix         # driver NVIDIA + CUDA
    │   └── gaming.nix         # Steam, Lutris, emuladores, gamemode
    └── hosts/
        └── <host>/
            ├── configuration.nix           # ponto de entrada do host
            └── hardware-configuration.nix   # scan de hardware (gerado por host)
```

### Regra de ouro: onde colocar cada coisa?

- **Vale para todas as máquinas?** → módulo `common/` apropriado (veja tabela abaixo).
- **É específico de hardware/uso de um host?** → `modules/` (importado só por quem precisa) ou direto no `hosts/<host>/configuration.nix`.
- **É o scan de hardware?** → `hosts/<host>/hardware-configuration.nix` (nunca editar à mão; regenerar com `nixos-generate-config`).

| Você quer adicionar…                    | Arquivo                        |
|-----------------------------------------|--------------------------------|
| Pacote CLI/sistema genérico             | `common/base.nix`              |
| App de desktop / tema / Zsh             | `common/desktop.nix`           |
| Ferramenta de dev / linguagem / cloud   | `common/development.nix`       |
| Serviço de sistema (daemon, porta)      | `common/services.nix`          |
| Driver/opção de GPU NVIDIA              | `modules/nvidia.nix`           |
| Steam/emuladores                        | `modules/gaming.nix`           |
| Algo só de um host                      | `hosts/<host>/configuration.nix` |

Referência rápida de onde já moram opções: `programs.zsh`→desktop · `services.keyd`/`services.syncthing`/`windowManager.qtile`→services · `programs.firefox`→base · `virtualisation.docker`→development · `hardware.nvidia`→nvidia · `programs.steam`→gaming.

---

## Adicionar um novo host

1. Gerar o hardware scan **na máquina alvo**: `nixos-generate-config --show-hardware-config > hosts/<novo>/hardware-configuration.nix`.
2. Criar `hosts/<novo>/configuration.nix` copiando o do `navi`: importar `hardware-configuration.nix` + os `common/*` desejados (+ `modules/*` se precisar), setar `networking.hostName` e `services.syncthing.dataDir`.
3. Registrar em `flake.nix`: `nixosConfigurations.<novo> = nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = [ ./nixos/hosts/<novo>/configuration.nix ]; };`
4. Aplicar na máquina: `sudo nixos-rebuild switch --flake .#<novo>`.

### Ativar `fi` (pendente)

O `fi` já está registrado e sua config está pronta (NVIDIA RTX 4060 c/ PRIME offload + gaming ativos, LV de Docker de 250G, swap 24G p/ hibernação). Falta só instalar na máquina real: (a) `hosts/fi/hardware-configuration.nix` ainda é **placeholder** — será substituído pelo scan real (`nixos-generate-config --no-filesystems --root /mnt`) durante o `nixos-install`; (b) o wiring do disko no `flake.nix` vive na branch de instalação `fi-disko`. Runbook completo em **AGENTS.md**.

---

## Esquema de disco (LVM sobre LUKS, /home separado)

Padrão de particionamento para **todas as máquinas**, declarado com [disko](https://github.com/nix-community/disko) — reprodutível e versionado, sem instalador gráfico:

```
disco → GPT
├─ ESP (1G, vfat, /boot)          não criptografado (EFI)
└─ LUKS (100%)  ── uma senha ──→  LVM (VG "pool")
                                   ├─ lv swap (8G; navi=8G, fi=24G p/ hibernação)
                                   ├─ lv root (ext4, /)     ← /nix/store (+ /var/lib/docker se não houver LV docker)
                                   ├─ lv docker (ext4, /var/lib/docker)  ← opcional (dockerSize); fi=250G
                                   └─ lv home (resto, ext4, /home) ← seus dados
```

Por quê: **uma senha** no boot; **`/home` separado** sobrevive a reinstalar o SO (NixOS ou Ubuntu) sem restaurar backup; volumes LVM **redimensionáveis** depois (`lvresize`+`resize2fs`), sem reinstalar. Um **LV dedicado ao Docker** (fi) impede que imagens acumuladas encham o `/` e travem o sistema.

- Helper reutilizável: `nixos/common/disko-lvm-luks.nix` (função `{ device, swapSize?, rootSize?, dockerSize? }`).
- Por host: `nixos/hosts/<host>/disko.nix` informa o `device` e, opcionalmente, `rootSize`/`swapSize`/`dockerSize` (navi=`/dev/sda`, root 70G, sem LV docker; fi=`/dev/nvme0n1`, swap 24G, root 100G, docker 250G). Default do helper: root 80G, swap 8G, sem LV docker.
- Wiring do build fica na branch de instalação (ver **AGENTS.md** → “Instalar/reinstalar um host com disko”), para não referenciar volumes inexistentes no sistema em execução.

**Reinstalar mantendo `/home`:** boot no live USB → recuperar o repo (clone do GitHub ou copiar da partição LUKS atual antes de destruir) → `disko --mode destroy,format,mount ./nixos/hosts/<host>/disko.nix` → `nixos-generate-config --no-filesystems --root /mnt` → `nixos-install --flake .#<host>`. Runbook completo no AGENTS.md.

## Verificar que uma mudança não quebra o setup

Antes de migrar/refatorar, confirme que a nova config reproduz a antiga comparando as *closures* (é assim que a migração modular do `navi` foi validada):

```bash
# build da nova config
nixos-rebuild build --flake .#navi && mv result result-new
# build da config de referência (ex.: outra revisão via git worktree) → result-old
nix store diff-closures ./result-old ./result-new   # diff vazio = equivalente
```

Detalhes e convenções para automação em **[AGENTS.md](./AGENTS.md)**.

---

## Troubleshooting

**Rebuild falha:** `sudo nixos-rebuild switch --flake . --show-trace` para o erro completo; `sudo nixos-rebuild --rollback switch` para voltar.

**Docker "permission denied":** grupo aplicado em `development.nix`; faça logout/login ou `newgrp docker`.

**Syncthing:** serviço de **sistema** (`systemctl status syncthing`), UI em `http://<host>.local:8384`. Diretório por host via `services.syncthing.dataDir`.

**Keyd não responde:** `sudo systemctl status keyd` / `sudo journalctl -u keyd -f`. Saída de emergência: `Esc+Backspace+Enter`.

**Gerações antigas:** listar com `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system`; limpar com `sudo nix-collect-garbage --delete-older-than 30d`.

**Atualizar nixpkgs:** `nix flake update` e reaplicar.

---

## Documentação por fase

A migração inicial Ubuntu→NixOS está documentada em `FASE1-*.md`..`FASE5-*.md` e `CUSTOM-PACKAGES.md` (como adicionar pacotes fora do nixpkgs via overlay). Refletem o estado do configuration.nix monolítico original — úteis como referência do *porquê* de cada configuração, mas a estrutura atual é a modular descrita acima.
