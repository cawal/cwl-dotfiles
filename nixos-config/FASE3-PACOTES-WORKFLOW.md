# FASE 3: Pacotes Essenciais do Workflow ✅

## O que foi adicionado

Esta fase adiciona todos os pacotes essenciais para seu workflow diário, organizados por categoria.

---

## Categorias de Pacotes

### 1. Node.js Ecosystem
```nix
nodejs_22                # Node.js LTS version 22
nodePackages.pnpm        # pnpm package manager
nodePackages.mermaid-cli # Mermaid diagram generation
```

**Comandos disponíveis:**
```bash
node --version
npm --version    # vem com nodejs
npx --version    # vem com nodejs
pnpm --version
mmdc --version   # mermaid-cli
```

**Observação sobre nvm/asdf:**
- Não use `nvm` ou `asdf` no NixOS
- Use `nodejs` global para desenvolvimento geral
- Para projetos com versões específicas, use `direnv` + `flake.nix`

---

### 2. Java & Diagramas
```nix
jre              # Java Runtime Environment
plantuml         # PlantUML diagram tool
graphviz         # Dependency for PlantUML
```

**Como usar:**
```bash
# PlantUML
plantuml diagram.puml

# Ou inline
echo "@startuml\nAlice -> Bob: Hello\n@enduml" | plantuml -pipe > output.png
```

---

### 3. Cloud & Infrastructure
```nix
google-cloud-sdk      # gcloud, gsutil, bq
kubectl               # Kubernetes CLI
kubernetes-helm       # Helm charts
terraform             # Infrastructure as Code
```

**Comandos disponíveis:**
```bash
gcloud --version
kubectl version --client
helm version
terraform --version
```

**Configuração inicial:**
```bash
# GCloud
gcloud init
gcloud auth login

# Kubectl (configure seu cluster)
kubectl config view
```

---

### 4. Data Tools
```nix
yq-go            # YAML/JSON processor
q-text-as-data   # Query CSV with SQL
jq               # JSON processor (já tinha)
csvkit           # CSV manipulation
```

**Exemplos de uso:**
```bash
# yq - processar YAML
yq '.spec.containers[0].image' deployment.yaml

# q - query CSV como SQL
q "SELECT * FROM file.csv WHERE column > 100"

# jq - processar JSON
curl api.com/data | jq '.results[] | .name'

# csvkit
csvcut -c 1,3 data.csv          # selecionar colunas
csvsql --query "SELECT * FROM data WHERE age > 30" data.csv
```

---

### 5. Development Tools
```nix
vscode           # Visual Studio Code (Microsoft)
postman          # API testing
insomnia         # API client
dbeaver-bin      # Universal database manager
```

**Observações:**
- VSCode: versão oficial da Microsoft (com suporte a extensions marketplace)
- DBeaver: versão binary (mais estável no NixOS)
- Insomnia: cliente REST/GraphQL
- Postman: ferramenta completa de API testing

---

### 6. Python Tools
```nix
python3
python3Packages.pip
pipx             # Install Python apps isolated
uv               # Fast Python package manager
```

**Como usar (substituindo venv/virtualenv):**

```bash
# Instalar app Python globalmente (isolado)
pipx install black
pipx install poetry

# Usar uv (muito mais rápido que pip)
uv pip install requests
uv venv .venv
source .venv/bin/activate

# pip tradicional ainda funciona
pip install --user some-package
```

**Observação sobre sdkman/pyenv:**
- Não use no NixOS
- Use `python3` global ou `direnv` para projetos específicos

---

### 7. Search & CLI Tools
```nix
silver-searcher  # ag - code search
ripgrep          # rg - fast search (já tinha)
fzf              # fuzzy finder (já tinha)
httpie           # HTTP client
entr             # run commands on file change
shellcheck       # shell script linter
xdotool          # X11 automation
htop             # process viewer
cloc             # count lines of code
```

**Exemplos de uso:**
```bash
# ag - buscar em código
ag "function.*search" --python

# httpie - HTTP requests
http GET https://api.github.com/users/cawal

# entr - watch files
ls *.py | entr pytest

# shellcheck - lint scripts
shellcheck script.sh

# cloc - count code
cloc src/
```

---

### 8. Desktop Utilities
```nix
greenclip        # Clipboard manager (integra com rofi)
gpick            # Color picker GUI
```

**Configuração do greenclip:**
```bash
# Iniciar daemon (adicionar ao autostart do qtile)
greenclip daemon &

# Usar com rofi
rofi -modi "clipboard:greenclip print" -show clipboard
```

**Uso do gpick:**
```bash
gpick  # abre GUI, clique em cores para copiar código hex
```

---

### 9. Communication & Entertainment
```nix
discord          # Chat/voice
retroarch        # Gaming emulator
slack            # Team communication (já tinha)
```

---

### 10. Desktop Environment Tools
```nix
i3lock              # Screen locker
dunst               # Notification daemon
picom               # Compositor (transparência, sombras)
flameshot           # Screenshot tool
lxappearance        # GTK theme manager
pavucontrol         # Audio volume control
```

**Integração com Qtile:**
- `dunst`: notificações funcionam automaticamente
- `picom`: adicionar ao autostart para transparência
- `flameshot`: bind para tecla de screenshot

---

### 11. Browsers
```nix
firefox          # Mozilla Firefox (já habilitado)
google-chrome    # Google Chrome (já tinha)
qutebrowser      # Keyboard-driven browser
```

---

### 12. Productivity
```nix
libreoffice      # Office suite
keepassxc        # Password manager
```

---

### 13. Media Tools
```nix
vlc              # Media player
audacity         # Audio editor
inkscape         # Vector graphics (SVG)
gimp             # Image editor
imagemagick      # CLI image manipulation
calibre          # E-book manager
```

---

### 14. File Management
```nix
file-roller      # Archive manager (zip, tar, etc)
baobab           # Disk usage analyzer
ranger           # Terminal file manager (já tinha)
```

---

### 15. Network Tools
```nix
networkmanagerapplet  # NetworkManager tray icon
tcpflow               # TCP flow recorder
tmate                 # Terminal sharing (like tmux but shareable)
```

---

## Pacotes que NÃO foram adicionados (e por quê)

### Supabase CLI
- Não tem pacote oficial no nixpkgs ainda
- **Solução:** instalar via `npm`:
  ```bash
  npm install -g supabase
  # ou
  npx supabase <command>
  ```

### Raindrop / Resterm
- Não encontrados no nixpkgs
- **Solução:** usar AppImage ou Flatpak se disponível

### Claude Code / OpenCode
- OpenCode já está instalado
- Claude Code (se for extensão): instalar via VSCode

---

## Como aplicar as mudanças

```bash
# 1. Rebuildar o sistema (vai demorar - muitos pacotes)
sudo nixos-rebuild switch

# Aguarde... pode levar 10-20 minutos dependendo da internet
```

---

## Verificação Pós-Instalação

```bash
# Node.js
node --version && npm --version && pnpm --version

# Cloud tools
gcloud --version && kubectl version --client && terraform --version

# Python
python3 --version && uv --version && pipx --version

# Data tools
yq --version && q --version && jq --version

# Dev tools
code --version && docker --version

# Search tools
ag --version && rg --version
```

---

## Comandos que agora funcionam

Todos esses comandos estarão disponíveis globalmente:

```bash
# Desenvolvimento
node npm npx pnpm mmdc plantuml terraform kubectl helm

# Data & CLI
yq q jq ag rg fzf http entr shellcheck cloc

# Python
python3 pip pipx uv

# Cloud
gcloud gsutil kubectl helm terraform

# GUI Apps
code postman insomnia dbeaver discord retroarch
vlc audacity inkscape gimp gpick keepassxc libreoffice

# Sistema
htop xdotool greenclip flameshot
```

---

## Integração com Zsh

Seu `.zshrc` deve parar de quebrar agora, pois as dependências dos plugins estão instaladas:

- ✅ `kubectl` plugin → kubectl instalado
- ✅ `helm` plugin → helm instalado
- ✅ `gcloud` plugin → google-cloud-sdk instalado
- ✅ `docker` plugin → docker instalado (FASE 2)

**Plugins que ainda precisam de ajuste:**
- `nvm` → remover do `.zshrc` (não usar no NixOS)
- `asdf` → remover do `.zshrc` (não usar no NixOS)

---

## Próximos passos

✅ FASE 1 completa  
✅ FASE 2 completa  
✅ FASE 3 completa  
⏭️ FASE 4: Configuração do Zsh (limpar nvm/asdf, ajustar PATH)
