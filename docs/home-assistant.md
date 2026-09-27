# Home Assistant no `fi` — sob demanda

Documento de referência sobre o Home Assistant (HA) hospedado no `fi`: por que ele
roda em container e não pelo módulo nativo do NixOS, quanto custa em recursos, como
ligar e desligar, como atualizar e como migrar para outra máquina.

> **Escopo:** LAN doméstica, HTTP puro, sem TLS nem acesso externo — mesma postura
> do WebDAV do Zotero (ver [arquitetura-rede-e-sync-zotero.md](./arquitetura-rede-e-sync-zotero.md), §5).
> **Modo de operação: sob demanda.** O serviço **não** sobe no boot.

---

## 1. Por que este desenho

| Decisão | Motivo |
| --- | --- |
| **Container oficial** (`ghcr.io/home-assistant/home-assistant`) em vez de `services.home-assistant` | No módulo nativo, cada integração precisa entrar em `extraComponents`, que é *build input* do derivation `homeassistant` → toda integração nova custa um rebuild local com a suíte de testes. Na fase de descobrir o que dá pra controlar, isso é atrito puro. Com a imagem, qualquer integração funciona na hora, pela UI. |
| **Sob demanda** (`autoStart = false`) | O `fi` é a máquina de trabalho. O unit nasce sem `wantedBy`, e o interruptor é o `cwl-ha`. |
| **Tetos por flag do `docker run`** | Com backend Docker o container **não** roda no cgroup do unit systemd (quem o cria é o `dockerd`), então `MemoryMax`/`CPUQuota` no unit seriam inócuos. |
| **Host network** | Descoberta na LAN (SSDP, mDNS, DHCP) e callbacks de dispositivos não atravessam a bridge NAT do Docker. |
| **Imagem pinada por versão** | `:stable` muda debaixo dos pés; um restart qualquer viraria upgrade não planejado (e o HA não suporta downgrade). |

**Custo do container:** a configuração do HA vive em `/var/lib/hass`, fora do Nix —
não é declarativa. Aceito conscientemente: é o preço de poder testar integrações sem
rebuild.

## 2. Impacto em recursos

Medido/estimado no `fi` (Intel Core Ultra 7 155H, 22 threads, 15 GiB de RAM):

| Recurso | Custo do HA | Teto configurado | Veredito |
| --- | --- | --- | --- |
| CPU | 1–3% de **um** núcleo em idle | `--cpus=2` (de 22 threads), `--cpu-shares=512` | irrelevante |
| RAM | ~400–600 MiB (HA core, integrações Wi-Fi/nuvem) | `--memory=2g`, `--memory-swap=2g` | ~4% da RAM; é o recurso que mais pesa |
| Swap | zero | `--memory-swap` igual a `--memory` | deliberado: o `fi` já vive com vários GiB de swap ocupados |
| Disco | imagem ~1 GiB + `/var/lib/hass` (SQLite, alguns MiB/dia) | — | monitorar: `/` tem ~29 GiB livres |
| I/O | o *recorder* grava SQLite continuamente | — | baixo, mas constante |

Na prática: **trabalhar com o HA ligado não é perceptível.** O que realmente limita
não é o peso, é o notebook suspender (ver §7).

## 3. Operação

Tudo pelo `bin/cwl-ha` (disponível no PATH via `make link-bin`):

```bash
cwl-ha start      # liga (1º start baixa a imagem, ~1 GiB, e cria /var/lib/hass)
cwl-ha stop       # desliga e devolve a RAM
cwl-ha restart    # após bump de imagem, ou se o resume deixar o HA estranho
cwl-ha status     # estado do serviço + memória livre
cwl-ha logs       # journalctl -f do unit
cwl-ha top        # consumo atual vs. teto
cwl-ha open       # abre http://localhost:8123
```

Por baixo é só `systemctl {start,stop} docker-home-assistant.service`.

**Acesso:** `http://fi.local:8123` (porta 8123/tcp aberta no firewall). No primeiro
start, o onboarding pede criar a conta local; depois, **Settings → Devices & Services**
mostra o que foi autodescoberto na rede.

**Conferir que está no ar e que os tetos estão valendo:**

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://fi.local:8123/   # → 302 (redirect p/ a UI)
# não use `curl -I`: o HA responde 405 a HEAD, o que parece erro e não é

cwl-ha top   # a coluna LIMIT deve mostrar 2GiB
CID=$(docker inspect -f '{{.Id}}' home-assistant)
cat /sys/fs/cgroup/system.slice/docker-$CID.scope/memory.max       # → 2147483648
cat /sys/fs/cgroup/system.slice/docker-$CID.scope/memory.swap.max  # → 0
```

> O `Memory:` que o `systemctl status` mostra (~11 MiB) é só o processo cliente do
> `docker` — o container vive em outro cgroup. Para o consumo real, `cwl-ha top`.

### Onde ficam os dados

| Caminho | Conteúdo |
| --- | --- |
| `/var/lib/hass/` | Tudo: `configuration.yaml`, `.storage/` (entidades, integrações, credenciais), `home-assistant_v2.db` (histórico do recorder) |
| `/var/lib/hass/backups/` | Backups gerados pelo próprio HA (Settings → System → Backups) |

O container é descartável — ao parar, o `oci-containers` o remove
(`autoRemoveOnStop`). O estado **é** o diretório acima.

## 4. Atualizar a imagem

O HA lança uma versão por mês. **Não existe downgrade**: o primeiro start de uma
versão nova migra o schema do banco, sem volta.

```bash
# 1. qual é o release atual
curl -s https://api.github.com/repos/home-assistant/core/releases/latest | jq -r .tag_name

# 2. editar a tag em nixos/common/home-assistant.nix (variável `image` no let)
# 3. aplicar e reiniciar
nixos-rebuild build --flake .#fi          # sem sudo, como manda nixos/AGENTS.md
sudo nixos-rebuild switch --flake .#fi
cwl-ha restart                            # pull da nova imagem no start
```

Antes de um bump grande, vale um backup pela UI (Settings → System → Backups).

## 5. Backup e migração

> **Gap conhecido:** `bin/cwl-backup` faz `rsync` só de `/home` — **`/var/lib/hass`
> não está coberto.** Mesma situação do `/var/lib/zotero-webdav`.

Backup manual:

```bash
sudo tar -C /var/lib -czf ~/hass-$(date +%F).tar.gz hass
```

Migrar para outra máquina (o cenário previsto: sair do notebook de trabalho para
hardware dedicado):

```bash
cwl-ha stop                                              # no fi, com o HA parado
sudo rsync -aH /var/lib/hass/ novo-host:/var/lib/hass/
# no novo host: importar ../../common/home-assistant.nix em hosts/<host>/configuration.nix
# e remover o import do fi
```

Nada mais precisa ser recriado — o `.storage/` leva integrações, dispositivos e
automações junto.

## 6. Interação com o resto da máquina

- **`autoPrune` do Docker:** `nixos/common/development.nix` roda uma poda semanal.
  O `--all` foi **removido** de propósito: com o HA parado não existe container
  referenciando a imagem, e `docker system prune --all` a apagava, forçando
  re-download de ~1 GiB no start seguinte. Hoje a poda só remove camadas *dangling*;
  limpeza agressiva virou manual (`docker system prune -a`).
  - Alternativa considerada e **não** adotada: `imageFile = pkgs.dockerTools.pullImage {...}`
    deixa a imagem no store (imune a qualquer poda), mas custa ~1,4 GiB duplicados
    em disco e exige fixar digest + hash a cada bump.
- **Avahi:** o `fi` já publica `fi.local` na 5353/udp. O HA, em host network, também
  fala mDNS (via `python-zeroconf`, com `SO_REUSEPORT`) — convivem. Se a descoberta
  por mDNS falhar, é o primeiro lugar a olhar.
- **Suspend/resume:** o unit `home-assistant-resume` roda `systemctl try-restart` ao
  acordar. Como `try-restart` é no-op em unit inativo, se o HA estava desligado ele
  continua desligado.

## 7. Limitações conhecidas

- **Automação só funciona com o serviço ligado e a máquina acordada.** Notebook
  suspenso = nenhuma automação. Este setup é bancada de teste; automação séria pede
  hardware dedicado ligado 24/7 (a migração está na §5).
- **Sem add-ons.** O ecossistema de add-ons (o "Supervisor") só existe no HA OS /
  Supervised. Em container, o equivalente é subir cada serviço à parte.
- **Sem TLS, LAN apenas.** Igual ao WebDAV: sem port-forward no roteador, é
  inacessível de fora de casa.
- **Config do HA fora do Nix.** Reinstalar o `fi` do zero exige restaurar
  `/var/lib/hass` do backup.

## 8. Próximos passos (fora do escopo atual)

- **Zigbee/Z-Wave:** exige dongle USB + `services.mosquitto` + `services.zigbee2mqtt`
  (ou `services.zwave-js`), e o dongle passado ao container via a opção `devices`.
  Ambos existem no nixpkgs 26.05. Atenção: desligar o HA sob demanda deixa a malha
  Zigbee sem coordenador.
- **Matter/Thread:** `services.matter-server` (+ `openthread-border-router` para Thread).
- **Bluetooth:** montar `/run/dbus` no container.
- **Acesso fora de casa:** Tailscale, já recomendado em
  [arquitetura-rede-e-sync-zotero.md](./arquitetura-rede-e-sync-zotero.md) §5 —
  resolve criptografia e acesso remoto de uma vez, sem dor de certificado.

## 9. Arquivos relevantes no repositório

| Arquivo | Papel |
| --- | --- |
| `nixos/common/home-assistant.nix` | Módulo: container, tetos, firewall, restart pós-resume |
| `nixos/hosts/fi/configuration.nix` | Importa o módulo (só no `fi`) |
| `nixos/common/development.nix` | Docker + `autoPrune` (sem `--all`, ver §6) |
| `bin/cwl-ha` | Interruptor: start/stop/restart/status/logs/top/open |
