# Agent skills declarativas — mesmo modelo do nix-flatpak (common/services.nix):
# a lista `skills` abaixo é a FONTE DE VERDADE, e um passo de ativação roda
# `npx skills` no rebuild para instalar as que faltarem. Como o Flathub, NÃO é
# pinado — pega a versão atual do repo de origem a cada instalação.
#
# Estado gerenciado pela ferramenta oficial:
#   - store canônico:  ~/.agents/skills/<name>/
#   - symlinks por agente: ~/.claude/skills/<name> -> ../../.agents/skills/<name>
#   - lock: ~/.agents/.skill-lock.json
#
# Para ADICIONAR uma skill: descubra o nome com `npx skills add <owner>/<repo> -l`
# e acrescente uma linha em `skills`. Rode `nixos-rebuild switch`. (Remover da
# lista NÃO desinstala — ver nota "prune" no fim.)
{ lib, pkgs, ... }:

let
  # Seletor global de agentes: quem recebe as skills por padrão. Espelha o
  # conjunto que já uso (lastSelectedAgents do lock). Vira valor comma-separated
  # do --agent. Cada skill pode sobrescrever com o campo `agents`.
  defaultAgents = [
    "claude-code"
    "opencode"
    "codex"
    "cursor"
    "amp"
    "gemini-cli"
    "zed"
    "github-copilot"
    "warp"
    "cline"
    "kimi-code-cli"
    "deepagents"
    "antigravity"
    "antigravity-cli"
  ];

  # source = "<owner>/<repo>" no GitHub; name = nome da skill (valor do -s, igual
  # ao diretório instalado em ~/.agents/skills/). `agents` omitido => defaultAgents.
  skills = [
    { name = "vercel-react-best-practices"; source = "vercel-labs/agent-skills"; }
    { name = "web-design-guidelines";       source = "vercel-labs/agent-skills"; }
    { name = "skill-creator";               source = "anthropics/skills"; }
    { name = "solresol";                    source = "cawal/skill-solresol"; agents = [ "claude-code" ]; }
    { name = "claude-handoff";                    source = "mattpocock/skills"; agents = [ "claude-code" ]; }
    { name = "find-skills";                 source = "vercel-labs/skills"; }
    { name = "tlc-spec-driven";             source = "tech-leads-club/agent-skills"; }
    { name = "defuddle";                    source = "kepano/obsidian-skills"; }
    { name = "json-canvas";                 source = "kepano/obsidian-skills"; }
    { name = "obsidian-bases";              source = "kepano/obsidian-skills"; }
    { name = "obsidian-cli";                source = "kepano/obsidian-skills"; }
    { name = "obsidian-markdown";           source = "kepano/obsidian-skills"; }
    { name = "html-artifacts";              source = "cawal/html-effectiveness-skill"; }
    { name = "easy-bug-reports";            source = "turi-saude/skills"; }
  ];

  # npx precisa de node + git no PATH durante a ativação (o HM não os expõe).
  binPath = lib.makeBinPath [ pkgs.nodejs pkgs.git ];

  addOne = s:
    let agents = lib.concatStringsSep "," (s.agents or defaultAgents);
    in ''
      if [ ! -e "$HOME/.agents/skills/${s.name}" ]; then
        echo "skills: instalando ${s.name} (${s.source}) -> ${agents}"
        PATH="${binPath}:$PATH" \
          npx --yes skills add "${s.source}" -s "${s.name}" \
              --global -y --agent "${agents}" \
          || echo "skills: FALHA ao instalar ${s.name} (segue o rebuild)"
      fi
    '';
in
{
  # Roda após o writeBoundary (arquivos do HM já linkados). Cada `npx` é
  # protegido por `|| echo`, então falha de rede/skill nova NÃO aborta o
  # nixos-rebuild switch. Com tudo já presente, o passo é no-op (rebuild offline
  # passa normalmente).
  home.activation.installAgentSkills =
    lib.hm.dag.entryAfter [ "writeBoundary" ]
      (lib.concatMapStrings addOne skills);

  # NOTA (prune): ao contrário do nix-flatpak, remover uma skill da lista NÃO a
  # desinstala (evita ação destrutiva). Para remover de fato:
  #   npx skills remove <name>
}
