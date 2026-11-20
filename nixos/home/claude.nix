# Configuração do Claude Code versionada em ../../claude/.
#
# Só CONFIG entra no repo. Fica de fora tudo o que é estado ou pessoal:
# ~/.claude.json (conta, confiança por projeto), .credentials.json,
# projects/ (transcripts e memórias), history.jsonl, plugins/ (cache) e
# ~/.claude/settings.local.json — este é o lugar para config pessoal mas não
# secreta (ex.: aprovação dos MCPs de trabalho do ~/.mcp.json). Segredos nunca
# vão para o repo: entram como ${VAR}, vindas do ~/.zsh_local.
#
# Por que symlink por item e não a pasta ~/.claude inteira: ela tem ~1 GB de
# credenciais, transcripts e memórias; dentro do repo, um `git clean -fdX`
# apagaria tudo e um `!` errado no .gitignore vazaria.
#
# Os links são VIVOS (mkOutOfStoreSymlink): o que o Claude grava (/model,
# /config, /plugin) cai direto no repo e aparece no `git diff`. Testado em
# 2026-11-20: `claude plugin disable/enable` grava através do symlink sem
# trocá-lo por arquivo comum.
{ config, lib, pkgs, ... }:

let
  repo = "/home/cawal/git/cwl-dotfiles/claude";
  link = name: config.lib.file.mkOutOfStoreSymlink "${repo}/${name}";

  # Arquivos e pastas linkados em ~/.claude/<nome>. As pastas vazias têm
  # .gitkeep no repo para marcar onde coisas novas entram.
  linked = [
    "settings.json"
    "CLAUDE.md"
    "keybindings.json"
    "rules"
    "agents"
    "commands"
    "output-styles"
  ];

  # Lidos na avaliação: são a fonte de verdade das activations abaixo.
  settings = builtins.fromJSON (builtins.readFile ../../claude/settings.json);
  mcpUser = builtins.fromJSON (builtins.readFile ../../claude/mcp-user.json);

  # O HM não recebe pkgsUnstable (sem extraSpecialArgs), e o claude-code vem
  # do sistema (common/development.nix). Na activation o perfil novo já está
  # em /run/current-system.
  claude = "/run/current-system/sw/bin/claude";
  jq = "${pkgs.jq}/bin/jq";
  binPath = lib.makeBinPath [ pkgs.nodejs pkgs.git ];

  pluginsDir = "$HOME/.claude/plugins";

  # O marketplace oficial é instalado sozinho pelo Claude, mas não aparece em
  # extraKnownMarketplaces; garantimos aqui para uma máquina nova.
  marketplaces = {
    claude-plugins-official = "anthropics/claude-plugins-official";
  } // lib.mapAttrs (_: m: m.source.repo) (settings.extraKnownMarketplaces or { });

  addMarketplace = name: src: ''
    if ! ${jq} -e --arg n "${name}" 'has($n)' "${pluginsDir}/known_marketplaces.json" >/dev/null 2>&1; then
      echo "claude: adicionando marketplace ${name} (${src})"
      PATH="${binPath}:$PATH" ${claude} plugin marketplace add "${src}" \
        || echo "claude: FALHA no marketplace ${name} (segue o rebuild)"
    fi
  '';

  # Só plugins habilitados (valor true) são instalados.
  enabledPlugins = lib.attrNames (lib.filterAttrs (_: v: v) (settings.enabledPlugins or { }));
  installPlugin = id: ''
    if ! ${jq} -e --arg p "${id}" '.plugins | has($p)' "${pluginsDir}/installed_plugins.json" >/dev/null 2>&1; then
      echo "claude: instalando plugin ${id}"
      PATH="${binPath}:$PATH" ${claude} plugin install "${id}" --scope user \
        || echo "claude: FALHA ao instalar ${id} (segue o rebuild)"
    fi
  '';

  # Confere direto no ~/.claude.json (escopo user) em vez de `claude mcp get`,
  # que também enxerga o escopo project do ~/.mcp.json e daria falso positivo.
  addMcp = name: cfg: ''
    if ! ${jq} -e --arg n "${name}" '.mcpServers // {} | has($n)' "$HOME/.claude.json" >/dev/null 2>&1; then
      echo "claude: adicionando MCP ${name} (escopo user)"
      ${claude} mcp add-json --scope user "${name}" ${lib.escapeShellArg (builtins.toJSON cfg)} \
        || echo "claude: FALHA no MCP ${name} (segue o rebuild)"
    fi
  '';
in
{
  home.file = lib.listToAttrs (map (name: {
    name = ".claude/${name}";
    value.source = link name;
  }) linked);

  # Mesmo modelo do skills.nix: instala o que falta, nunca remove (tirar da
  # lista não desinstala; use `claude plugin uninstall` / `claude mcp remove`).
  # Cada chamada tem `|| echo`: sem rede o rebuild segue, e com tudo presente
  # o passo não faz nada.
  home.activation.claudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (lib.mapAttrsToList addMarketplace marketplaces)
    + lib.concatMapStrings installPlugin enabledPlugins
    + lib.concatStrings (lib.mapAttrsToList addMcp mcpUser)
  );
}
