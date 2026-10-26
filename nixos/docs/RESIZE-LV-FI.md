# Redimensionar os LVs do fi — raiz 100G → 200G

Procedimento para dar espaço à raiz do `fi` encolhendo o LV do Docker, e com
isso destravar `system.autoUpgrade` (atualizações automáticas de sistema).

**Estado de origem** (verificado em 2026-10-26):

```
pool-docker  250G alocados, 246G úteis,  32G em uso  →  /var/lib/docker
pool-root    100G alocados,  98G úteis,  60G em uso  →  /
pool-swap     24G                                    →  [SWAP]
pool-home    578,9G                                  →  /home
VG `pool`: 952,9G, 100% alocado (zero extent livre)
```

**Estado de destino**: `pool-docker` 150G, `pool-root` 200G. A soma dos dois é
350G antes e depois — de propósito, porque o LV de home é `100%FREE` no
`disko.nix`: mexer só nesses dois não desloca `/home` nem deixa extent sobrando.

## Por que isso é necessário

Um `switch` do NixOS é atômico: a closure atual e a nova coexistem durante a
operação, ~40G cada. Em 98G úteis com 60G já ocupados, não cabe. Testado em
2026-10-21 — o bump do pin estável encheu o disco e o build falhou. É por isso
que `system.autoUpgrade` está desligado, e é esse o item que fica "parcial" no
relatório de postura de segurança.

## O que este procedimento NÃO é

**O `disko.nix` não redimensiona nada num sistema em execução.** Ele é consumido
de duas formas: pelo `disko run` num live USB (instalação do zero) e pelo build
do sistema, onde só gera as entradas de `fileSystems`/`swapDevices`. Mudar
`rootSize`/`dockerSize` lá mantém a declaração fiel para uma reinstalação
futura, mas o redimensionamento do disco vivo é manual, pelos passos abaixo.

Por isso a ordem correta é: executar os passos, e **só então** o
`nixos-rebuild`. O inverso não causa dano, apenas não faz nada.

## Riscos, sem rodeio

O único ponto de exposição real é o LV do Docker. `/` e `/home` **não são
desmontados nem truncados** em passo nenhum daqui.

A rota escolhida é **recriar** o LV do Docker, não encolher. Encolher um ext4
exige `resize2fs` com o filesystem desmontado, numa operação que realoca blocos
fisicamente — e uma interrupção nessa janela (queda de energia, OOM) deixa o
filesystem inconsistente. Como o conteúdo do LV é descartável (imagens
rebaixáveis + volumes de teste do Supabase local + build cache), recriar elimina
essa etapa inteira em vez de tentar sobreviver a ela.

**O que se perde ao recriar** (~32G, nada disso em `/` ou `/home`):

| Conteúdo | Tamanho | Recuperável? |
| --- | --- | --- |
| 31 imagens Docker | 18,46 GiB | Sim — baixam de novo no próximo `supabase start` |
| 46 volumes (banco de teste) | 10,73 GiB | **Não automaticamente** — ver Passo 0 |
| Build cache | 3,2 GiB | Sim — reconstrói |

As 71 migrations estão em git, então o *schema* se reconstrói sozinho. Mas não
existe `seed.sql` no projeto: o que estiver nesses volumes hoje foi criado à mão
e não volta por si.

Crescer a raiz, ao contrário, é seguro: `lvextend` + `resize2fs` para **crescer**
ext4 funciona online, com o filesystem montado e em uso, sem mover blocos.

## Passo 0 (opcional) — preservar os dados de teste do Supabase

Pule se os volumes são lixo de teste. Se não forem:

```bash
cd /home/cawal/git/turi/turisaude-lab
supabase start     # o dump exige o banco no ar
supabase db dump --data-only -f /home/cawal/supabase-test-data-$(date +%Y%m%d).sql
supabase stop
```

O arquivo vai para `/home`, que é outro LV e não é tocado pelo procedimento.

## Passo 1 — parar o Docker por completo

```bash
docker ps -q | wc -l                                    # esperado: 0
sudo systemctl stop docker.socket docker.service
systemctl is-active docker docker.socket                 # esperado: inactive inactive
```

O `docker.socket` tem de ser parado **junto e antes** do serviço: com ele ativo,
qualquer comando `docker` reativa o `dockerd` por socket activation no meio do
procedimento. O `containerd` não precisa ser parado à parte — neste host ele é
gerenciado pelo próprio `dockerd` ("starting managed containerd" no journal).

## Passo 2 — desmontar e confirmar que o LV está livre

```bash
sudo umount /var/lib/docker
findmnt /var/lib/docker                                  # esperado: nenhuma saída
```

Se o `umount` reclamar que está ocupado, descubra quem segura antes de insistir:

```bash
sudo fuser -vm /var/lib/docker
```

## Passo 3 — recriar o LV do Docker com 150G

```bash
sudo lvremove pool/docker        # pede confirmação; é aqui que os 32G vão embora
sudo vgs pool                    # esperado: VFree 250,00g
sudo lvcreate -L 150G -n docker pool
sudo mkfs.ext4 /dev/pool/docker
```

O nome do LV tem de continuar `docker` no VG `pool`: o `/etc/fstab` monta por
**caminho de device** (`/dev/pool/docker`), não por UUID, então recriar com o
mesmo nome mantém a montagem válida sem precisar preservar UUID. O `mkfs` vai
sem `-L` porque o filesystem original também não tinha label.

## Passo 4 — crescer a raiz para 200G (online, com o sistema em uso)

```bash
sudo lvextend -L 200G /dev/pool/root     # equivale a -l +100%FREE neste ponto
sudo resize2fs /dev/pool/root
df -h /                                   # esperado: ~196G úteis
```

Não precisa desmontar, não precisa reboot, não precisa modo single-user.

## Passo 5 — remontar e subir o Docker

```bash
sudo mount /var/lib/docker
sudo systemctl start docker.socket docker.service
docker info | grep -i "docker root dir"   # esperado: /var/lib/docker
docker images | wc -l                      # esperado: 1 (só o cabeçalho)
```

## Passo 6 — conferir o resultado

```bash
sudo vgs pool                              # esperado: VFree 0
lsblk -o NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT /dev/nvme0n1
df -h / /var/lib/docker /home
```

O `disko.nix` do host já declara 200G/150G — é só conferir que bate com o que o
`lsblk` mostra, para que uma reinstalação futura reproduza o mesmo layout.

Para repor o ambiente de teste:

```bash
cd /home/cawal/git/turi/turisaude-lab && supabase start
# e, se fez o Passo 0:
psql "$(supabase status -o json | jq -r .DB_URL)" -f /home/cawal/supabase-test-data-AAAAMMDD.sql
```

## Passo 7 — habilitar as atualizações automáticas

Com a raiz em 197G úteis e 128G livres, as duas closures passam a caber com
folga. O bloco já está habilitado em `nixos/common/security.nix`:

```nix
system.autoUpgrade = {
  enable = true;
  flake = "/home/cawal/git/cwl-dotfiles#fi";
  operation = "boot";          # ativa no próximo boot, sem switch ao vivo
  upgrade = false;             # `--upgrade` é flag de canal, inútil com flake
  dates = "Mon 03:00";
  randomizedDelaySec = "45min";
  persistent = true;
  allowReboot = false;
};
```

O comando resultante, conferido por `nix eval` antes do switch:

```
nixos-rebuild boot --refresh --flake /home/cawal/git/cwl-dotfiles#fi
```

Aplique com:

```bash
sudo nixos-rebuild switch --flake /home/cawal/git/cwl-dotfiles#fi
systemctl list-timers | grep nixos-upgrade
```

Três ressalvas que valem a leitura antes de ligar:

1. **Assim, sem `flags`, o timer reconstrói o que já está no lock — ou seja, não
   atualiza nada.** Isso é útil de propósito na primeira semana: valida que o
   timer roda, constrói e gera a geração sem encher o disco, com risco zero.
   Para passar a atualizar de verdade, acrescente
   `flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ]`.
2. `--update-input` está **deprecado** no Nix (hoje 2.34.7 aqui, ainda aceita) em
   favor de `nix flake update <input>`. Se um dia parar de funcionar, a
   alternativa é um `preStart` no serviço rodando `nix flake update nixpkgs` no
   repositório.
3. Com `--commit-lock-file`, o timer **faz commit no repositório** — commits
   autorados por `root` em `flake.lock`, e a árvore precisa estar limpa no
   horário agendado. Se isso incomodar, a saída é a mesma do item 2: um passo
   explícito, em vez de delegar a mutação do git ao módulo.

`nix.gc` continua semanal com `--delete-older-than 30d`, e isso deve ser
**mantido**, não apertado: atualização não supervisionada é justamente a
situação em que se quer uma geração antiga para dar rollback. Seis gerações
ocupavam 38,8–39,6 GiB num store de 43 GiB (medido em 2026-10-21) — elas
compartilham quase tudo, então guardar histórico é barato.

## Se algo der errado

- **`lvremove` feito e `lvcreate` falhou**: nada além do LV do Docker foi
  afetado. Repita o Passo 3; o Docker sobe com data root vazio.
- **`resize2fs` do root interrompido**: crescer é a direção segura (não realoca
  dados), mas se a máquina não subir, dê boot por live USB e rode
  `e2fsck -f /dev/pool/root`.
- **Boot falha depois do Passo 3**: o fstab monta `/dev/pool/docker` com
  `defaults 0 2` — se o LV não existir, o systemd degrada a montagem mas o
  sistema sobe. Confirme com `systemctl status var-lib-docker.mount`.
- **Reverter tudo**: é o mesmo procedimento com os números trocados — encolher a
  raiz, porém, exige `resize2fs` offline, que é o passo que esta rota evitou.
  Na prática, reverter é mais caro que avançar.
