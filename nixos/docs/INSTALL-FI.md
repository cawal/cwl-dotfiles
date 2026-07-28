# Instalar o NixOS no `fi` (disko: LVM-on-LUKS + LV Docker + NVIDIA)

Guia passo a passo para instalar o host **`fi`** do zero, a partir de um live USB do
NixOS. Reinstala o disco inteiro com particionamento declarativo (disko) e deixa a
máquina pronta com NVIDIA (PRIME offload), Docker isolado e limpezas automáticas.

> ⚠️ **Este processo APAGA todo o disco do `fi`** (`/dev/nvme0n1`). O `/home` também é
> recriado — faça backup do que precisar antes.

Todo o wiring do disko vive na branch **`fi-disko`** (ver [AGENTS.md](./AGENTS.md) →
"Instalar/reinstalar um host com disko"). Use-a **só** para o `nixos-install`.

---

## O que vai ser criado no disco (`/dev/nvme0n1`, ~1024G)

```
/dev/nvme0n1 → GPT
├─ ESP   1G    vfat  /boot                       (não criptografado)
└─ LUKS  100%  ── uma senha ──→ LVM (VG "pool")
                                ├─ lv swap    24G   (hibernação; RAM 16G + folga)
                                ├─ lv root   100G   ext4  /                (SO + /nix/store)
                                ├─ lv docker 250G   ext4  /var/lib/docker  (Docker isolado)
                                └─ lv home   resto  ext4  /home            (~578G)
```

- **Uma senha LUKS** no boot destrava tudo.
- **`/var/lib/docker` num LV próprio**: imagens Docker acumulando não enchem o `/`.
- **`/home` separado**: sobrevive a reinstalar o SO sem restaurar backup.
- Tamanhos definidos em [`nixos/hosts/fi/disko.nix`](./nixos/hosts/fi/disko.nix); podem
  ser redimensionados depois com `lvresize` + `resize2fs` (LVM), sem reinstalar.

---

## Pré-requisitos

- Live USB do **NixOS** (de preferência a mesma série, 25.11/26.05) com internet.
- O repositório já commitado e no GitHub na branch `fi-disko` (feito).
- Saber a senha que você quer para o **LUKS** (define no passo 4) e para o **root**
  (define no passo 6). A senha do usuário `cawal` já vem da config (`hashedPassword`).

---

## Passo a passo (no live USB)

### 1. Recuperar o repositório e entrar na branch de instalação
```bash
git clone https://github.com/cawal/cwl-dotfiles.git && cd cwl-dotfiles
git checkout fi-disko && cd nixos-config
```
> Alternativa sem rede: 2º pendrive com o repo já clonado, ou copiar da partição LUKS
> atual **antes** de destruir o disco. Se usar pendrive, rode
> `git config --global --add safe.directory "$PWD"` para evitar "dubious ownership".

### 2. (Opcional) Validar a config sem tocar no disco
```bash
nixos-rebuild build --flake .#fi
```
Isso avalia o `disko.devices` e constrói o toplevel — se falhar aqui, pare e corrija
antes de mexer no disco.

### 3. Confirmar o bus ID do iGPU Intel
```bash
lspci | grep -E 'VGA|3D|Display'
```
- Se o **Intel** aparecer como `00:02.0` → **nada a fazer** (já configurado como
  `PCI:0:2:0` em [`nixos/modules/nvidia.nix`](./nixos/modules/nvidia.nix)).
- Se for outro endereço → edite o campo `intelBusId` em `nixos/modules/nvidia.nix`
  convertendo de **hex para decimal** no formato `PCI:bus:device:function`.
  Ex.: `00:0a.0` (hex `0a` = 10) → `intelBusId = "PCI:0:10:0";`.
  Não há comando extra: o valor entra sozinho no `nixos-install` do passo 6.
- O NVIDIA (`01:00.0` → `PCI:1:0:0`) normalmente não muda.

### 4. Particionar, formatar e montar (DESTRÓI o disco)
```bash
sudo nix run --extra-experimental-features "flakes nix-command" \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./nixos/hosts/fi/disko.nix
```
O disko vai **pedir a senha do LUKS** aqui (digite a que você quer usar no boot).
Ao fim, o disco novo está montado em `/mnt`.

### 5. Gerar o hardware real
```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```
Isso substitui o **stub** `hosts/fi/hardware-configuration.nix` pelos kernel modules
reais desta máquina. O `--no-filesystems` é essencial: os filesystems/swap/LUKS são
fornecidos pelo disko, não por este arquivo.
> Copie o resultado gerado para `nixos/hosts/fi/hardware-configuration.nix` se o
> `nixos-generate-config` gravar em `/mnt/etc/nixos` em vez do repo.

### 6. Instalar
```bash
sudo nixos-install --flake .#fi
```
Ao final ele pede **a senha do root**. A senha do usuário `cawal` já vem da config.

### 7. Reboot
```bash
reboot
```
No boot, o sistema pede **uma senha** (a do LUKS, definida no passo 4).

---

## Logo após o primeiro login — TROCAR A SENHA

A senha do `cawal` vem de um `hashedPassword` versionado num repo **público**, então
é **temporária**. Troque imediatamente (o `users.mutableUsers = true` faz a nova senha
persistir):
```bash
passwd
```

---

## Verificação pós-instalação

```bash
# Disco isolado: docker num LV separado do /
lsblk                     # deve mostrar pool-swap / pool-root / pool-docker / pool-home
df -h / /var/lib/docker   # /var/lib/docker num filesystem próprio

# Limpezas automáticas (timers systemd)
systemctl list-timers | grep -E 'docker-prune|nix-gc'

# Docker
docker info | grep "Root Dir"     # /var/lib/docker
docker run --rm hello-world

# NVIDIA híbrido (PRIME offload)
nvidia-smi                              # dGPU responde
glxinfo | grep -i vendor                # sem offload → Intel (economiza bateria)
nvidia-offload glxinfo | grep -i vendor # com o wrapper → NVIDIA

# Firmware (paridade com o Ubuntu, via fwupd)
fwupdmgr get-devices
fwupdmgr refresh && fwupdmgr get-updates

# Hibernação (swap 24G dentro do LUKS)
systemctl hibernate       # religar → sessão deve voltar
```

---

## Depois: manutenção normal (no próprio `fi`)

Como o `fi` foi instalado *greenfield* com o pool já existindo, depois de instalado é
seguro rodar `nixos-rebuild switch` normalmente:
```bash
cd ~/git/cwl-dotfiles   # flake na raiz do repo (pós-reestruturação)
sudo nixos-rebuild switch --flake .#fi
```
As limpezas rodam sozinhas (Docker prune semanal, `nix.gc` 30d). Para forçar na mão:
`docker system prune --all` / `sudo nix-collect-garbage --delete-older-than 30d`.

---

## Se algo der errado

- **Build falha no passo 2/6:** rode com `--show-trace` para o erro completo.
- **Não loga após instalar:** confirme que trocou a senha (`passwd`) ou que o
  `hashedPassword` está presente em `common/base.nix`.
- **Tela preta / X não sobe:** provavelmente o `intelBusId` está errado (passo 3).
  Boot num TTY (`Ctrl+Alt+F3`), corrija `nixos/modules/nvidia.nix` e
  `sudo nixos-rebuild switch --flake .#fi`.
- **initrd não acha o NVMe:** você pulou o passo 5. Boot no live USB, refaça o
  `nixos-generate-config --no-filesystems --root /mnt` e reinstale.
