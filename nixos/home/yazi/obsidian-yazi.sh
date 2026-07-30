# obsidian-yazi <subcomando> [arquivos...] — ponte do yazi para operar num
# vault do Obsidian via CLI. Detecta a raiz do vault subindo até `.obsidian` e
# converte os caminhos absolutos (vindos do yazi via %h/%s) em caminhos
# relativos ao vault, que é o que o `obsidian` espera. Ver keymap.toml (prefixo
# `o`). Requer o Obsidian aberto com o vault-alvo carregado.
#
# Empacotado por writeShellApplication (nixos/home/cawal.nix): o shebang e
# `set -euo pipefail` são injetados; NÃO adicionar aqui. O build roda shellcheck.

notify() { notify-send -a "yazi → obsidian" "$1" "${2:-}" 2>/dev/null || true; }
die_notify() { notify "$1" "${2:-}"; exit 1; }

# O CLI do Obsidian deixa o terminal em raw mode; sob o --block do yazi isso
# faz o Enter virar ^M e o `read` nunca completar. Restaura o modo canônico
# (icanon/echo/icrnl) antes de qualquer leitura interativa.
tty_sane() { stty sane </dev/tty 2>/dev/null || true; }

# Pausa aguardando Enter (usado sob --block, após mostrar saída/erro).
pause() { tty_sane; printf '\n[Enter para voltar ao yazi] '; read -r _ </dev/tty || true; }

# ask "prompt" -> resposta no stdout (prompt vai pro tty, não é capturado).
ask() {
  local __r=""
  tty_sane
  printf '%s' "$1" >/dev/tty
  IFS= read -r __r </dev/tty || true
  printf '%s' "$__r"
}

# Sobe a partir de $1 até achar a raiz do vault (diretório `.obsidian`).
find_vault() {
  local d="$1"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    [ -d "$d/.obsidian" ] && { printf '%s\n' "$d"; return 0; }
    d="$(dirname "$d")"
  done
  return 1
}

# rel_to_vault <vault> <abs> -> caminho relativo à raiz do vault.
rel_to_vault() {
  local r
  r="${2#"$1"}"
  printf '%s' "${r#/}"
}

cmd="${1:-}"
shift || true
[ -z "$cmd" ] && die_notify "obsidian-yazi" "Nenhum subcomando informado."

# Âncora para achar o vault: 1º arquivo passado, senão o diretório atual.
anchor="$PWD"
[ "$#" -gt 0 ] && anchor="$1"
vault="$(find_vault "$anchor")" \
  || die_notify "Fora de um vault" "O alvo não está dentro de um vault do Obsidian."
vault_name="$(basename "$vault")"

# Caminho do 1º arquivo relativo ao vault (comandos de arquivo único usam %h).
hovered_rel=""
[ "$#" -gt 0 ] && hovered_rel="$(rel_to_vault "$vault" "$1")"

# Guardas de pré-condição por família de comando.
case "$cmd" in
  open|rename|prop|backlinks|links|outline)
    if [ -z "$hovered_rel" ]; then
      die_notify "Nenhum arquivo" "Passe o cursor sobre uma nota."
    fi ;;
  move|delete)
    if [ "$#" -eq 0 ]; then
      die_notify "Nada selecionado" "Selecione ao menos um arquivo."
    fi ;;
esac

case "$cmd" in
  # --- move: move os selecionados para o diretório atual, corrige wikilinks ---
  move)
    dest_rel="$(rel_to_vault "$vault" "$PWD")"
    [ -z "$dest_rel" ] && dest_rel="/"
    ok=0; fail=0; errmsg=""
    for f in "$@"; do
      case "$f" in "$vault"/*) : ;; *) fail=$((fail + 1)); errmsg="Fora do vault: $f"; continue ;; esac
      src_rel="$(rel_to_vault "$vault" "$f")"
      if out="$(obsidian vault="$vault_name" move path="$src_rel" to="$dest_rel" 2>&1)"; then
        ok=$((ok + 1))
      else
        fail=$((fail + 1)); errmsg="$out"
      fi
    done
    if [ "$fail" -eq 0 ]; then
      notify "Movido(s) $ok arquivo(s)" "→ ${dest_rel}  (vault: ${vault_name})"
    else
      die_notify "Movidos $ok · falharam $fail" "$errmsg"
    fi ;;

  # --- open: abre a nota sob o cursor no app Obsidian ------------------------
  open)
    if obsidian vault="$vault_name" open path="$hovered_rel" >/dev/null 2>&1; then
      notify "Aberto no Obsidian" "$hovered_rel"
    else
      die_notify "Falha ao abrir" "$hovered_rel"
    fi ;;

  # --- rename: renomeia corrigindo os wikilinks (input interativo) -----------
  rename)
    cur="$(basename "$hovered_rel")"
    printf 'Renomear (corrige wikilinks): %s\n' "$hovered_rel" >/dev/tty
    new="$(ask "Novo nome [$cur]: ")"
    [ -z "$new" ] && { printf 'Cancelado.\n' >/dev/tty; exit 0; }
    if out="$(obsidian vault="$vault_name" rename path="$hovered_rel" name="$new" 2>&1)"; then
      notify "Renomeado" "$cur → $new"
    else
      printf '%s\n' "$out" >/dev/tty; pause; die_notify "Falha no rename" "$out"
    fi ;;

  # --- delete: apaga os selecionados; mostra PARA ONDE vão (config do vault) -
  delete)
    # trashOption do vault: system (lixeira do SO), local (.trash) ou none.
    topt="$(obsidian vault="$vault_name" eval code="app.vault.getConfig('trashOption')||'system'" 2>/dev/null || true)"
    topt="${topt#*> }"; topt="${topt//[[:space:]]/}"
    case "$topt" in
      system) tdesc="lixeira do sistema (~/.local/share/Trash)" ;;
      local)  tdesc="lixeira do vault (.trash)" ;;
      none)   tdesc="APAGADO PERMANENTEMENTE (sem lixeira!)" ;;
      *)      tdesc="lixeira ($topt)" ;;
    esac
    printf 'APAGAR → %s\n' "$tdesc" >/dev/tty
    for f in "$@"; do printf '  %s\n' "$(rel_to_vault "$vault" "$f")" >/dev/tty; done
    ans="$(ask "Confirma? [y/N]: ")"
    case "$ans" in y|Y|s|S) : ;; *) printf 'Cancelado.\n' >/dev/tty; exit 0 ;; esac
    ok=0; fail=0; errmsg=""
    for f in "$@"; do
      r="$(rel_to_vault "$vault" "$f")"
      if obsidian vault="$vault_name" delete path="$r" >/dev/null 2>&1; then
        ok=$((ok + 1))
      else
        fail=$((fail + 1)); errmsg="$r"
      fi
    done
    if [ "$fail" -eq 0 ]; then
      notify "Apagado(s) $ok arquivo(s)" "→ $tdesc"
    else
      die_notify "Apagados $ok · falharam $fail" "$errmsg"
    fi ;;

  # --- prop: define uma propriedade do frontmatter (input interativo) --------
  prop)
    printf 'Definir propriedade em: %s\n' "$hovered_rel" >/dev/tty
    pname="$(ask "Nome da propriedade: ")"
    [ -z "$pname" ] && { printf 'Cancelado.\n' >/dev/tty; exit 0; }
    pval="$(ask "Valor: ")"
    if out="$(obsidian vault="$vault_name" property:set path="$hovered_rel" name="$pname" value="$pval" 2>&1)"; then
      notify "Propriedade definida" "$pname = $pval"
    else
      printf '%s\n' "$out" >/dev/tty; pause; die_notify "Falha em property:set" "$out"
    fi ;;

  # --- backlinks / links / outline: inspeção read-only (mostra e espera) -----
  backlinks|links|outline)
    case "$cmd" in
      backlinks) out="$(obsidian vault="$vault_name" backlinks path="$hovered_rel" counts 2>&1)" || true ;;
      links)     out="$(obsidian vault="$vault_name" links path="$hovered_rel" 2>&1)" || true ;;
      outline)   out="$(obsidian vault="$vault_name" outline path="$hovered_rel" 2>&1)" || true ;;
    esac
    printf '# %s — %s\n\n%s\n' "$cmd" "$hovered_rel" "$out"
    pause ;;

  # --- search: busca texto no vault com contexto (input interativo) ----------
  search)
    q="$(ask "Buscar no vault ($vault_name): ")"
    [ -z "$q" ] && exit 0
    out="$(obsidian vault="$vault_name" search:context query="$q" 2>&1)" || true
    printf '%s\n' "$out"
    pause ;;

  # --- create: cria uma nota nova no diretório atual e abre no app -----------
  create)
    dest_rel="$(rel_to_vault "$vault" "$PWD")"
    printf 'Nova nota em: %s\n' "${dest_rel:-raiz do vault}" >/dev/tty
    name="$(ask "Nome da nota: ")"
    [ -z "$name" ] && { printf 'Cancelado.\n' >/dev/tty; exit 0; }
    npath="$name.md"
    [ -n "$dest_rel" ] && npath="$dest_rel/$name.md"
    if out="$(obsidian vault="$vault_name" create path="$npath" open 2>&1)"; then
      notify "Nota criada e aberta" "$vault_name/$npath"
    else
      printf '%s\n' "$out" >/dev/tty; pause; die_notify "Falha ao criar" "$out"
    fi ;;

  *)
    die_notify "obsidian-yazi" "Subcomando desconhecido: $cmd" ;;
esac
