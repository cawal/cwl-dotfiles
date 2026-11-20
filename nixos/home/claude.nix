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
{ config, lib, ... }:

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
in
{
  home.file = lib.listToAttrs (map (name: {
    name = ".claude/${name}";
    value.source = link name;
  }) linked);
}
