# CWL Dotfiles - NixOS Configuration

Configuração completa do NixOS para o sistema **navi**, com suporte a desenvolvimento, ambiente desktop (Qtile), e acesso remoto.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Como Aplicar](#como-aplicar)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Funcionalidades Configuradas](#funcionalidades-configuradas)
- [Workflow de Desenvolvimento](#workflow-de-desenvolvimento)
- [Troubleshooting](#troubleshooting)
- [Diferenças Ubuntu → NixOS](#diferenças-ubuntu--nixos)

---

## 🎯 Visão Geral

Este repositório contém:
- **Configuração NixOS declarativa** (`nixos-config/`)
- **Dotfiles tradicionais** gerenciados via `stow` (vim, tmux, qtile, etc)
- **Documentação detalhada** de cada fase da migração

### Sistema Alvo

- **Hostname:** navi
- **OS:** NixOS 26.05
- **Desktop:** Qtile (window manager)
- **Shell:** Zsh + Oh My Zsh
- **Acesso:** SSH, Syncthing, mDNS (navi.local)

---

## 🚀 Como Aplicar

### Primeira Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/cwl-dotfiles.git ~/git/cwl-dotfiles
cd ~/git/cwl-dotfiles

# 2. Checkout branch NixOS
git checkout nixos-navi

# 3. Aplicar configuração NixOS
cd nixos-config
sudo nixos-rebuild switch --flake . --impure

# 4. Fazer logout/login para aplicar todas mudanças
```

### Atualizações Futuras

```bash
cd ~/git/cwl-dotfiles/nixos-config

# Testar mudanças (temporário)
sudo nixos-rebuild test --flake . --impure

# Aplicar permanentemente
sudo nixos-rebuild switch --flake . --impure

# Rollback se algo quebrar
sudo nixos-rebuild --rollback switch
```

### Aplicar Dotfiles (stow)

```bash
cd ~/git/cwl-dotfiles

# Aplicar configurações específicas
stow zsh
stow vim
stow qtile
stow tmux
stow rofi

# Ou usar o Makefile (se preferir)
make configure
```

---

## 📁 Estrutura do Repositório

```
cwl-dotfiles/
├── nixos-config/              # Configuração NixOS
│   ├── flake.nix             # Entrada principal
│   ├── nixos/
│   │   └── configuration.nix # Configuração do sistema
│   ├── FASE1-*.md            # Documentação detalhada
│   ├── FASE2-*.md
│   ├── FASE3-*.md
│   ├── FASE4-*.md
│   └── FASE5-*.md
│
├── zsh/                       # Dotfiles Zsh
├── vim/                       # Dotfiles Vim/Neovim
├── qtile/                     # Configuração Qtile
├── tmux/                      # Configuração Tmux
├── rofi/                      # Temas Rofi
├── i3/                        # Configuração i3 (legado)
└── Makefile                   # Helper para Ubuntu (legado)
```

---

## ✨ Funcionalidades Configuradas

### 🌐 Rede e Acesso Remoto

- ✅ **mDNS/Avahi**: acesso via `navi.local`
- ✅ **SSH**: acesso seguro (porta 22, apenas usuário cawal)
- ✅ **Syncthing**: sincronização de arquivos
  - UI acessível em: `http://navi.local:8384`
  - Protegida por senha

### 🐳 Virtualização e Containers

- ✅ **Docker**: daemon ativo, usuário no grupo docker (sem sudo)
- ✅ **AppImage**: suporte completo via binfmt

### 🎨 Desktop Environment

- ✅ **Qtile**: window manager principal
- ✅ **GNOME/GDM**: fallback desktop
- ✅ **Rofi**: launcher de aplicações
- ✅ **Greenclip**: gerenciador de clipboard
- ✅ **Keyd**: remapeamento de teclado
  - Caps Lock → Esc (tap) / Nav layer (hold)
  - Space → Meta (hold)
  - Navegação vim-style: Caps+hjkl
- ✅ **Bluetooth**: gerenciado via Blueman

### 💻 Desenvolvimento

#### Node.js Ecosystem
- nodejs (v22 LTS)
- pnpm
- npx
- mermaid-cli

#### Cloud & Infrastructure
- gcloud (Google Cloud SDK)
- kubectl
- helm
- terraform

#### Python
- python3
- pip
- uv (package manager moderno)

#### Databases & APIs
- dbeaver
- postman
- insomnia

#### Editores
- neovim
- vscode (Microsoft)

#### CLI Tools
- fzf, ripgrep, silver-searcher
- httpie, curl, wget
- jq, yq, q (CSV query)
- shellcheck, cloc
- git, gh

### 🎮 Produtividade & Entretenimento

- Firefox, Chrome, Qutebrowser
- LibreOffice
- KeePassXC
- Discord
- VLC, Audacity
- Inkscape, GIMP
- RetroArch

### 🔧 Sistema

- Zsh + Oh My Zsh (tema agnoster)
- Tmux
- Ranger
- Kitty terminal

---

## 🔄 Workflow de Desenvolvimento

### Gerenciamento de Pacotes

#### ❌ Não use mais (Ubuntu way)
```bash
# Não funciona no NixOS
nvm install 18
asdf install python 3.11
sudo apt install pacote
```

#### ✅ Use agora (NixOS way)

**Global (em configuration.nix):**
```nix
environment.systemPackages = with pkgs; [
  nodejs_22
  python3
];
```

**Por projeto (com direnv):**
```bash
# No diretório do projeto
cat > shell.nix <<EOF
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_18  # Versão específica do projeto
    python311
  ];
}
EOF

echo "use nix" > .envrc
direnv allow
```

### Docker

```bash
# Funciona sem sudo
docker run hello-world
docker compose up -d

# Verificar status
docker ps
systemctl status docker
```

### Python Virtual Environments

```bash
# Usar uv (mais rápido)
uv venv .venv
source .venv/bin/activate
uv pip install requests

# Ou pip tradicional
python -m venv .venv
source .venv/bin/activate
pip install requests
```

### Clipboard Manager (Greenclip)

```bash
# Usar com rofi
rofi -modi "clipboard:greenclip print" -show clipboard

# Ou criar binding no Qtile
# Super+v para abrir histórico
```

---

## 🔧 Troubleshooting

### Zsh não é shell padrão

```bash
echo $SHELL
# Se não for /run/current-system/sw/bin/zsh

# Fazer logout/login
# Ou manualmente:
chsh -s $(which zsh)
```

### Docker: "permission denied"

```bash
# Verificar grupo
groups | grep docker

# Se não aparecer, fazer logout/login
# Ou:
newgrp docker
```

### Syncthing UI não abre

```bash
# Verificar serviço
systemctl --user status syncthing

# Ver logs
journalctl --user -u syncthing -f

# Reiniciar
systemctl --user restart syncthing
```

### Syncthing não inicia

**Erro:** `Failed to ensure directory exists (error="mkdir /var/lib/syncthing: permission denied")`

**Causa:** Diretórios não existem ou têm permissões incorretas.

**Solução:** A configuração já inclui `systemd.tmpfiles.rules` que cria os diretórios automaticamente. Se precisar corrigir manualmente:

```bash
# Criar diretórios com permissões corretas
sudo mkdir -p /var/lib/syncthing/.config/syncthing
sudo chown -R cawal:users /var/lib/syncthing
sudo chmod 700 /var/lib/syncthing

# Reiniciar serviço
sudo systemctl restart syncthing

# Verificar status
sudo systemctl status syncthing
```

**Acesso à UI:** http://localhost:8384 ou http://navi.local:8384

### Syncthing - Múltiplas instâncias

Se você tinha Syncthing rodando como usuário antes:

```bash
# Parar instância do usuário
systemctl --user stop syncthing

# Desabilitar autostart
systemctl --user disable syncthing

# Usar apenas o serviço do sistema (recomendado)
sudo systemctl status syncthing
```

### Keyd não responde

```bash
# Verificar serviço
sudo systemctl status keyd

# Ver logs
sudo journalctl -u keyd -f

# Reiniciar
sudo systemctl restart keyd

# Emergency exit: Esc+Backspace+Enter
```

### Rebuild falha

```bash
# Ver erro detalhado
sudo nixos-rebuild switch --flake . --impure --show-trace

# Rollback para versão anterior
sudo nixos-rebuild --rollback switch

# Listar gerações disponíveis
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

---

## 📊 Diferenças Ubuntu → NixOS

| Aspecto | Ubuntu (antes) | NixOS (agora) |
|---------|----------------|---------------|
| Instalação de pacotes | `apt install` | Declarativo em `configuration.nix` |
| Versões de Node | `nvm` | `nodejs_XX` ou `direnv` |
| Versões de Python | `pyenv` / `venv` | `pythonXX` ou `direnv` |
| Configuração de serviços | Arquivos em `/etc/` | Declarativo no `.nix` |
| Rollback | Manual | Automático (`--rollback`) |
| Dotfiles | `stow` apenas | `stow` + NixOS modules |
| Keyd config | Arquivo em `/etc/keyd/` | Declarativo no `.nix` |
| Oh My Zsh | Script de instalação | Gerenciado pelo NixOS |

---

## 📚 Documentação Detalhada

Cada fase da migração está documentada em detalhes:

- **[FASE1-REDE-SYNCTHING-SSH.md](./FASE1-REDE-SYNCTHING-SSH.md)**: Configuração de rede e acesso remoto
- **[FASE2-DOCKER-APPIMAGE-BLUETOOTH.md](./FASE2-DOCKER-APPIMAGE-BLUETOOTH.md)**: Virtualização e hardware
- **[FASE3-PACOTES-WORKFLOW.md](./FASE3-PACOTES-WORKFLOW.md)**: Todos os pacotes de desenvolvimento
- **[FASE4-ZSH-CONFIGURATION.md](./FASE4-ZSH-CONFIGURATION.md)**: Shell e ambiente de terminal
- **[FASE5-KEYD-CONFIGURATION.md](./FASE5-KEYD-CONFIGURATION.md)**: Remapeamento de teclado
- **[CUSTOM-PACKAGES.md](./CUSTOM-PACKAGES.md)**: Como adicionar pacotes não disponíveis no nixpkgs

---

## 🎯 Próximos Passos

### Tarefas Pendentes

- [ ] Ajustar plugins do Neovim que podem estar quebrados
- [ ] Configurar touchpad (libinput settings)
- [ ] Adicionar Dropbox (opcional)
- [ ] Testar supabase-cli (instalar via npm)
- [ ] Configurar autostart do greenclip no Qtile

### Melhorias Futuras

- [ ] Migrar mais configs de stow para NixOS modules
- [ ] Criar home-manager config
- [ ] Adicionar mais máquinas ao flake
- [ ] Configurar backups automáticos
- [ ] Documentar processo de instalação do zero

### ✅ Concluído

- [x] Syncthing rodando com permissões corretas
- [x] Homebank instalado (5.10.2)
- [x] .zshrc limpo (removido nvm, asdf, sdkman, aliases apt)
- [x] Aliases NixOS adicionados (nixos-update, nixos-upgrade)

---

## 📝 Notas Importantes

### Binary Cache

O NixOS baixa pacotes pré-compilados por padrão. Se você fizer overrides (como fizemos com terraform), vai recompilar localmente.

### Atualizações do Sistema

```bash
# Atualizar nixpkgs
sudo nix-channel --update

# Ou com flakes (recomendado)
nix flake update ~/git/cwl-dotfiles/nixos-config

# Aplicar atualizações
sudo nixos-rebuild switch --flake . --impure
```

### Limpeza de Gerações Antigas

```bash
# Listar gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Deletar gerações antigas (manter últimas 5)
sudo nix-collect-garbage --delete-older-than 30d

# Ou deletar tudo exceto geração atual
sudo nix-collect-garbage -d
```

---

## 🤝 Contribuindo

Este é um repositório de dotfiles pessoais, mas sinta-se livre para:
- Usar como inspiração para sua própria config
- Reportar issues se encontrar problemas
- Sugerir melhorias

---

## 📄 Licença

MIT License - use livremente!

---

## 🙏 Agradecimentos

- [NixOS](https://nixos.org) - sistema operacional declarativo
- [Oh My Zsh](https://ohmyz.sh) - framework Zsh
- [Qtile](http://www.qtile.org) - window manager em Python
- Comunidade NixOS pelos exemplos e documentação

---

**Última atualização:** $(date +%Y-%m-%d)  
**Branch:** nixos-navi  
**Sistema:** NixOS 26.05
