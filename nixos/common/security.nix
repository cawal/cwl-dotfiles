# Controles de segurança auditáveis: antimalware e atualizações.
# Arquivo separado porque é exatamente o que o pessoal de SI pede evidência —
# dá pra apontar pra ele num relatório em vez de caçar linhas no base.nix.

{ config, pkgs, ... }:

{
  # === Antimalware (equivalente ao XProtect do macOS) ===
  #
  # O XProtect não é um antivírus residente: é assinatura atualizada
  # automaticamente + verificação no momento da execução. A paridade honesta
  # aqui são as DUAS primeiras linhas (updater + varredura agendada). O clamd
  # residente é a mais, e está ligado por dois motivos práticos:
  #   1. numa auditoria, `systemctl is-active clamav-daemon` responder `active`
  #      vale mais que explicar que o antivírus roda on-demand;
  #   2. o scanner agendado do módulo é o `clamdscan`, que FALA com o daemon —
  #      o módulo tem assertion explícita (scanner -> daemon).
  #
  # Custo: o clamd mantém o banco de assinaturas inteiro na RAM (~1,3 GiB). Em
  # fi (15 GiB, com Supabase rodando) isso se nota. Se apertar, desligue
  # daemon+scanner e deixe só o updater, usando `clamscan` on-demand: o
  # relatório de SI continua tendo assinatura atualizada automaticamente.
  services.clamav = {
    daemon.enable = true;

    # freshclam. Padrões do módulo: timer horário, até 12 checagens/dia.
    # É este o equivalente direto ao auto-update das assinaturas do XProtect.
    updater.enable = true;

    scanner = {
      enable = true;
      # O padrão do módulo é DIÁRIO às 04:00 usando até 10 cores. Sobre um
      # /home de 259 GiB isso é hora(s) de CPU todo dia num desktop que
      # frequentemente está em uso ou suspenso. Semanal é o que se pratica em
      # estação de trabalho — e o Persistent abaixo garante que a varredura
      # atrasada rode, em vez de ser silenciosamente perdida.
      interval = "Sun 03:00";
    };
  };

  # Os timers do módulo não são persistentes: se a máquina estiver desligada ou
  # suspensa na hora marcada, a execução é simplesmente PERDIDA (e aí o
  # relatório de SI fica sem evidência de varredura). Persistent faz o systemd
  # rodar no próximo boot o que ficou para trás.
  systemd.timers.clamdscan.timerConfig.Persistent = true;
  systemd.timers.clamav-freshclam.timerConfig.Persistent = true;

  # O clamdscan do módulo roda com `--infected --allmatch`, ou seja: REPORTA e
  # não mexe no arquivo. Intencional — nada de quarentena/remoção automática
  # num /home de trabalho. O achado sai no journal: `journalctl -u clamdscan`.

  # === Atualizações automáticas (equivalente ao Software Update) ===
  #
  # O equivalente NixOS do unattended-upgrades é `system.autoUpgrade`, e ele
  # está DESLIGADO de propósito: o pool-root de fi não cabe o que um bump do
  # pin estável produz. Um switch é atômico, então as duas closures coexistem
  # (~40 GiB cada em 98 GiB de LV); testado em 2026-10-21, encheu o disco e o
  # build falhou. Ligar autoUpgrade aqui hoje significaria um timer semanal que
  # enche a raiz sem supervisão.
  #
  # Para ligar isto (e fechar o item do checklist de SI de verdade), falta UM
  # passo manual: encolher o pool-docker e crescer o pool-root para 200 GiB.
  # O procedimento está escrito e revisado em docs/RESIZE-LV-FI.md, e o
  # hosts/fi/disko.nix JÁ declara o layout de destino (200G/150G) — o disko não
  # redimensiona disco vivo, então a declaração está lá para a reinstalação
  # futura, e o redimensionamento em si é o documento.
  #
  # Feito o resize, descomente o bloco abaixo e rode o switch:
  #
  #   system.autoUpgrade = {
  #     enable = true;
  #     flake = "/home/cawal/git/cwl-dotfiles#fi";
  #     operation = "boot";      # nova geração no próximo boot, sem switch
  #     dates = "Mon 03:00";     # ao vivo numa máquina em uso
  #     randomizedDelaySec = "45min";
  #     persistent = true;
  #     allowReboot = false;
  #   };
  #
  # Assim, SEM `flags`, o timer reconstrói o que já está no lock — ou seja, não
  # atualiza nada. Isso é deliberadamente útil na primeira semana: prova que o
  # timer roda e constrói sem encher a raiz. Para atualizar de fato, acrescente
  # `flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ]`, ciente de que
  # (a) --update-input está deprecado no Nix e (b) o timer passa a fazer commit
  # como root no repositório. As ressalvas estão no Passo 7 do documento.
  #
  # Enquanto isso, o que ESTÁ automatizado e é auditável:
  #   - assinaturas de antimalware: timer clamav-freshclam (horário);
  #   - firmware: services.fwupd (ver common/services.nix);
  #   - coleta de lixo do store: nix.gc semanal (ver common/base.nix);
  #   - o pin das dependências é versionado em git: `git log -- flake.lock`
  #     mostra a cadência real de atualização.
}
