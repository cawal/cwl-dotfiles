# Home Assistant em container, SOB DEMANDA (só o host fi hospeda isto).
#
# POR QUE CONTAINER e não o módulo nativo `services.home-assistant`: no módulo
# nativo, cada integração precisa entrar em `extraComponents`, que é *build
# input* do derivation `homeassistant` — ou seja, toda integração nova custa um
# rebuild local com a suíte de testes ligada. Na fase de descobrir o que dá pra
# controlar em casa isso é atrito puro; com a imagem oficial toda integração
# funciona na hora, direto pela UI. O preço é abrir mão do declarativo dentro do
# HA (a config dele vive em /var/lib/hass, fora do Nix) — aceito conscientemente.
#
# POR QUE SOB DEMANDA: o fi é a máquina de trabalho. `autoStart = false` faz o
# unit nascer sem `wantedBy`, então o HA não sobe no boot — sobe quando eu mando,
# com `cwl-ha start` (ver bin/cwl-ha). Consequência a não esquecer: automação só
# roda enquanto o serviço está ligado E a máquina acordada. Isto aqui é bancada
# de teste; automação de verdade pede hardware dedicado (a migração é barata:
# todo o estado está em /var/lib/hass).
#
# POR QUE HOST NETWORK: o HA depende de descoberta na LAN (SSDP, mDNS, DHCP) e de
# callbacks dos dispositivos, que não atravessam a bridge NAT do Docker. Com host
# network o `-p` é ignorado — quem expõe a porta é o firewall, no fim do arquivo.
#
# POR QUE OS TETOS VÊM POR FLAG DO DOCKER: com backend Docker o container NÃO roda
# no cgroup do unit systemd (quem o cria é o dockerd), então MemoryMax/CPUQuota no
# unit seriam inócuos. O limite real tem de ser `docker run --memory/--cpus`.
#
# BUMP DA IMAGEM e operação (backup, migração, Zigbee): docs/home-assistant.md.
{ config, pkgs, lib, ... }:

let
  stateDir = "/var/lib/hass";
  port = 8123;
  # Imagem PINADA — nada de :stable, que muda debaixo dos pés. 2026.9.4 é o
  # release de 2026-09-27. Bump: ver docs/home-assistant.md (downgrade do HA não
  # é suportado; o primeiro start de uma versão nova migra o schema do banco).
  image = "ghcr.io/home-assistant/home-assistant:2026.9.4";
in
{
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.home-assistant = {
    inherit image;

    # O coração do "sob demanda": sem autoStart o módulo gera o unit
    # docker-home-assistant.service com `wantedBy = [ ]`.
    autoStart = false;
    # Não tenta rede a cada start; só baixa se a imagem não estiver local.
    pull = "missing";

    networks = [ "host" ];
    volumes = [ "${stateDir}:/config" ];
    environment.TZ = config.time.timeZone;

    extraOptions = [
      "--memory=2g" # teto duro (~13% da RAM); uso típico ~500 MiB
      # memory-swap IGUAL a memory => swap zero para o container. O fi já vive com
      # vários GiB de swap ocupados; o HA fica contido na RAM em vez de aumentar a
      # pressão de swap e tornar o desktop pastoso.
      "--memory-swap=2g"
      "--memory-reservation=768m" # alvo suave sob pressão de memória
      "--cpus=2" # 2 das 22 threads
      "--cpu-shares=512" # metade do peso default: cede CPU ao trabalho
      "--pids-limit=512"
    ];
  };

  # O bind mount precisa existir antes do primeiro start (senão o Docker cria o
  # caminho como root:root 0755 por conta própria).
  systemd.tmpfiles.rules = [ "d ${stateDir} 0750 root root -" ];

  # App do celular, tablet e descoberta de dispositivos. Mesma postura dos outros
  # serviços de casa: HTTP puro, confinado à LAN pelo firewall e pela ausência de
  # port-forward no roteador (ver docs/arquitetura-rede-e-sync-zotero.md, §5).
  networking.firewall.allowedTCPPorts = [ port ];

  # Depois de suspender, o HA acorda com salto de relógio e integrações penduradas.
  # `try-restart` reinicia só se o serviço estiver ativo — se o HA estava desligado,
  # isto é um no-op e ele continua desligado.
  systemd.services.home-assistant-resume = {
    description = "Reinicia o Home Assistant após resume (no-op se estiver parado)";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.systemd.package}/bin/systemctl try-restart docker-home-assistant.service";
    };
  };
}
