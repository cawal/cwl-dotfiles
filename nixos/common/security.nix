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
  # Equivalente NixOS do unattended-upgrades. Ficou desligado até 2026-10-26
  # por falta de espaço, não por escolha: um switch é atômico, então a closure
  # atual e a nova coexistem (~40 GiB cada), o que não cabia nos 98 GiB úteis
  # da raiz — testado em 2026-10-21, encheu o disco e o build falhou. Com o
  # resize dos LVs (raiz em 197 GiB úteis, 128 livres) isso deixou de valer.
  # Ver docs/RESIZE-LV-FI.md.
  system.autoUpgrade = {
    enable = true;
    flake = "/home/cawal/git/cwl-dotfiles#fi";

    # `boot`, não `switch`: a geração nova é construída e vira o padrão no
    # próximo boot, em vez de trocar o sistema por baixo de uma máquina em uso
    # às 3 da manhã. Reverter é escolher a geração anterior no menu de boot.
    operation = "boot";

    # O módulo acrescenta `--upgrade` ao nixos-rebuild quando `channel` é null,
    # e isso é um flag de CANAIS (nix-channel --update) que nada faz com flake —
    # a opção existe justamente para desligá-lo nesse caso. Sem isto o comando
    # semanal carrega um flag inútil, no melhor caso ignorado.
    upgrade = false;

    dates = "Mon 03:00";
    randomizedDelaySec = "45min";

    # Sem isto, uma semana em que a máquina estivesse desligada no horário
    # seria simplesmente perdida.
    persistent = true;

    # Nada de reboot automático numa estação de trabalho: quem reinicia é o
    # operador, e é no reboot que a geração nova entra.
    allowReboot = false;

    # NÃO há `flags` aqui, e isso é deliberado nesta primeira fase: sem elas o
    # timer reconstrói o que já está no flake.lock, ou seja, NÃO atualiza nada.
    # Serve para provar que o timer roda, constrói e gera a geração sem encher
    # a raiz — risco zero. Para passar a atualizar de fato:
    #
    #   flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
    #
    # ciente de duas coisas: (a) `--update-input` está deprecado no Nix (2.34.7
    # aqui, ainda aceita) em favor de `nix flake update <input>`, e se cair a
    # alternativa é um preStart rodando isso no repositório; (b) com
    # `--commit-lock-file` o timer passa a fazer commit COMO ROOT no repo, que
    # precisa estar limpo no horário agendado. Passo 7 de docs/RESIZE-LV-FI.md.
  };

  # O nix.gc semanal com `--delete-older-than 30d` (ver common/base.nix) deve
  # ser MANTIDO como está, não apertado: atualização não supervisionada é
  # justamente a situação em que se quer uma geração antiga para dar rollback.
  # Guardar histórico é barato — 6 gerações ocupavam 38,8–39,6 GiB num store de
  # 43 GiB (medido em 2026-10-21), porque compartilham quase tudo.

  # Resumo do que está automatizado e é auditável por timer systemd:
  #   - sistema: nixos-upgrade.timer (semanal, geração nova no próximo boot);
  #   - assinaturas de antimalware: clamav-freshclam.timer (horário);
  #   - varredura de antimalware: clamdscan.timer (semanal);
  #   - firmware: fwupd-refresh.timer (ver common/services.nix);
  #   - coleta de lixo do store: nix-gc.timer (ver common/base.nix).
  # A cadência das atualizações de pacote segue versionada em git:
  # `git log -- flake.lock`.
}
