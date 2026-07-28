# FASE 4: Configuração do Zsh ✅

## O que foi configurado

### 1. Zsh como Shell Padrão
```nix
users.users."cawal" = {
  shell = pkgs.zsh;
};

programs.zsh.enable = true;
```

**O que isso faz:**
- Zsh é o shell padrão para o usuário `cawal`
- Todos os novos terminais abrem com Zsh
- Login shell é Zsh

---

### 2. Oh My Zsh (Gerenciado pelo NixOS)
```nix
programs.zsh.ohMyZsh = {
  enable = true;
  theme = "agnoster";  # Seu tema atual
  plugins = [
    "git" "docker" "docker-compose"
    "kubectl" "helm" "terraform" "gcloud"
    "python" "pip" "systemd" "fzf"
  ];
};
```

**O que isso faz:**
- Oh My Zsh instalado e gerenciado pelo NixOS
- Tema `agnoster` (mesmo do seu `.zshrc`)
- Plugins essenciais pré-configurados
- Atualizações automáticas via `nixos-rebuild`

**Plugins removidos (não usar no NixOS):**
- ❌ `nvm` - não usar no NixOS
- ❌ `asdf` - não usar no NixOS

---

### 3. Features Adicionais
```nix
programs.zsh = {
  enableCompletion = true;          # Tab completion
  autosuggestions.enable = true;    # Fish-like suggestions
  syntaxHighlighting.enable = true; # Syntax highlighting
};
```

**O que isso faz:**
- **Completion**: autocompletar comandos e argumentos
- **Autosuggestions**: sugere comandos baseado no histórico (como Fish)
- **Syntax highlighting**: destaca comandos válidos/inválidos

---

### 4. Shell Init
```nix
shellInit = ''
  export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
  [[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"
'';
```

**O que isso faz:**
- Adiciona `~/bin` e `~/.local/bin` ao PATH
- Carrega `~/.zsh_local` se existir (para configs específicas da máquina)

---

## Convivência com seu `.zshrc` existente

Você tem duas opções:

### Opção 1: Híbrida (Recomendado para transição) ✅

Manter seu `.zshrc` do stow, mas **limpar** as partes que o NixOS já gerencia:

**Remover do seu `~/.zshrc`:**
```bash
# ❌ Remover estas linhas (NixOS gerencia)
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
ZSH_THEME="agnoster"

# ❌ Remover plugins que estão no NixOS
plugins=(git docker kubectl helm ...) 

# ❌ Remover carregamento de nvm/asdf
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
source $HOME/.asdf/asdf.sh
```

**Manter no seu `~/.zshrc`:**
```bash
# ✅ Manter seus aliases personalizados
alias vim='nvim'
alias k='kubectl'
# etc...

# ✅ Manter funções customizadas
function mkcd() { mkdir -p "$1" && cd "$1"; }

# ✅ Manter configurações específicas
export EDITOR=nvim
export VISUAL=nvim

# ✅ Carregar .zsh_local (já está no shellInit, mas não faz mal)
[[ -f "${HOME}/.zsh_local" ]] && source "${HOME}/.zsh_local"
```

---

### Opção 2: Full NixOS (Avançado)

Migrar tudo para o NixOS configuration.nix:

```nix
programs.zsh = {
  shellAliases = {
    vim = "nvim";
    k = "kubectl";
    dc = "docker-compose";
  };
  
  interactiveShellInit = ''
    # Suas funções e configs customizadas
    function mkcd() { mkdir -p "$1" && cd "$1"; }
  '';
};
```

**Não recomendado agora** - deixe isso para depois que validar tudo funcionando.

---

## Como aplicar as mudanças

```bash
# 1. Rebuildar o sistema
sudo nixos-rebuild switch

# 2. Abrir novo terminal
# Zsh deve ser o shell padrão automaticamente

# 3. Verificar
echo $SHELL
# Deve mostrar: /run/current-system/sw/bin/zsh

# 4. Verificar Oh My Zsh
echo $ZSH_THEME
# Deve mostrar: agnoster
```

---

## Limpando seu `.zshrc` (Tarefa Manual)

Aqui está um `.zshrc` limpo que funciona bem com o NixOS:

```bash
# ~/.zshrc - Versão NixOS-friendly

# Carregar configs locais/específicas da máquina
if [ -f "${HOME}/.zsh_local" ]; then
    source "${HOME}/.zsh_local"
fi

# ===== PATH customizado =====
# (NixOS já adiciona /usr/local/bin, etc automaticamente)
export PATH="$HOME/bin:$HOME/go/bin:$PATH"

# ===== Aliases =====
alias vim='nvim'
alias vi='nvim'
alias k='kubectl'
alias tf='terraform'
alias dc='docker-compose'
alias ll='ls -lah'
alias gs='git status'
alias gd='git diff'
alias gp='git push'
alias gl='git log --oneline'

# ===== Environment Variables =====
export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8

# ===== Custom Functions =====
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ===== FZF Integration =====
# (NixOS já configura o básico, mas você pode customizar)
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ===== History =====
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# ===== Direnv (if you use it) =====
# eval "$(direnv hook zsh)"

# ===== Local overrides =====
# Any machine-specific config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

---

## Migração de nvm/asdf → NixOS

### Antes (Ubuntu com nvm)
```bash
nvm install 18
nvm use 18
node --version
```

### Agora (NixOS)
```bash
# Opção 1: Global (já instalado)
node --version  # v22.x

# Opção 2: Por projeto (usando direnv + flake.nix)
cd meu-projeto/
echo "use flake" > .envrc
direnv allow

# No flake.nix do projeto:
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }: {
    devShell.x86_64-linux = 
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        buildInputs = [ pkgs.nodejs_18 ];  # Versão específica
      };
  };
}
```

---

## Usando direnv para projetos específicos

Instalar direnv (se ainda não tiver):

```nix
# Em configuration.nix, adicionar a environment.systemPackages:
direnv
```

Exemplo de uso:

```bash
# No projeto
cd ~/projetos/meu-app/
echo "use nix" > .envrc
direnv allow

# Agora toda vez que entrar na pasta, o ambiente é carregado
```

---

## Comandos que devem funcionar após rebuild

```bash
# Verificar Zsh
zsh --version
echo $SHELL

# Verificar Oh My Zsh
echo $ZSH
ls $ZSH/plugins

# Verificar theme
echo $ZSH_THEME

# Testar plugins
kubectl completion zsh   # deve funcionar
docker completion zsh    # deve funcionar

# Testar syntax highlighting
# Digite um comando válido → deve ficar verde
# Digite um comando inválido → deve ficar vermelho
```

---

## Troubleshooting

### Zsh não é o shell padrão
```bash
# Verificar shell atual
echo $SHELL

# Mudar manualmente (temporário)
chsh -s $(which zsh)

# Ou garantir via NixOS rebuild
sudo nixos-rebuild switch
```

### Oh My Zsh não carrega
```bash
# Verificar se está habilitado
echo $ZSH

# Deve mostrar algo como:
# /nix/store/...-oh-my-zsh-...

# Se não aparecer, verificar configuration.nix
```

### Plugins não funcionam
```bash
# Verificar se plugins estão carregados
echo $plugins

# Listar plugins disponíveis
ls $(dirname $ZSH)/plugins
```

### Comandos do .zshrc não funcionam
```bash
# Verificar se .zshrc está sendo carregado
echo "test" >> ~/.zshrc
# Abrir novo terminal e verificar se o erro aparece

# Debugar .zshrc
zsh -x  # Executa em modo debug
```

---

## Próximos passos

✅ FASE 1 completa  
✅ FASE 2 completa  
✅ FASE 3 completa  
✅ FASE 4 completa  
⏭️ FASE 5: keyd configuration (mapear teclas)

---

## Tarefa Manual (Fazer depois do rebuild)

1. ✅ Aplicar rebuild: `sudo nixos-rebuild switch`
2. ✅ Abrir novo terminal e verificar que Zsh funciona
3. ⚠️ **Limpar `~/.zshrc`** removendo linhas duplicadas com NixOS
4. ⚠️ **Remover instalação manual do Oh My Zsh** (se existir):
   ```bash
   # Verificar se existe
   ls ~/.oh-my-zsh
   
   # Se existir, pode remover (NixOS gerencia agora)
   rm -rf ~/.oh-my-zsh  # CUIDADO: só fazer se NixOS Oh-my-zsh funcionar
   ```
