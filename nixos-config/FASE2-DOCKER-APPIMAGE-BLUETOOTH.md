# FASE 2: Docker + AppImage + Bluetooth ✅

## O que foi configurado

### 1. Docker
```nix
virtualisation.docker = {
  enable = true;
  enableOnBoot = true;
};

users.users."cawal" = {
  extraGroups = [ "networkmanager" "wheel" "docker" ];
};
```

**O que isso faz:**
- Docker daemon instalado e rodando
- Inicia automaticamente no boot
- Usuário `cawal` no grupo `docker` (pode usar docker sem `sudo`)

**Como usar:**
```bash
# Testar
docker run hello-world

# Ver containers rodando
docker ps

# Docker Compose também está disponível (instalado automaticamente)
docker compose version
```

---

### 2. AppImage Support
```nix
programs.appimage = {
  enable = true;
  binfmt = true;  # Permite executar AppImages como binários normais
};
```

**O que isso faz:**
- Suporte completo para AppImages
- Permite executar AppImages diretamente (sem `chmod +x` manual)
- Monta automaticamente as dependências necessárias (FUSE)

**Como usar:**
```bash
# Baixar qualquer AppImage
wget https://example.com/app.AppImage

# Executar diretamente
./app.AppImage

# Ou tornar executável primeiro (método tradicional)
chmod +x app.AppImage
./app.AppImage
```

**Observação:** 
- AppImages agora funcionam nativamente
- Não precisa instalar `libfuse2` separadamente
- O NixOS fornece o ambiente necessário automaticamente

---

### 3. Bluetooth
```nix
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;  # Liga o adaptador Bluetooth no boot
};

services.blueman.enable = true;  # GUI manager
```

**O que isso faz:**
- Bluetooth habilitado e pronto para uso
- Adaptador liga automaticamente no boot
- Blueman fornece interface gráfica (ícone no tray)

**Como usar:**
```bash
# Via GUI (recomendado)
# - Ícone do Blueman deve aparecer no system tray do Qtile
# - Clicar para gerenciar dispositivos

# Via linha de comando
bluetoothctl
# > power on
# > scan on
# > pair <MAC_ADDRESS>
# > connect <MAC_ADDRESS>
```

**Integração com Qtile:**
- O widget `qtile-extras` pode mostrar status do Bluetooth
- Blueman tray icon aparece automaticamente
- Gerenciamento via GUI sem precisar abrir terminal

---

## Como aplicar as mudanças

```bash
# 1. Rebuildar o sistema
sudo nixos-rebuild switch

# 2. Fazer logout e login novamente
# (necessário para que o grupo 'docker' seja aplicado ao usuário)

# 3. Verificar se os serviços estão rodando
systemctl status docker
systemctl status bluetooth
```

---

## Como testar

### Teste 1: Docker (sem sudo)
```bash
# Este comando NÃO deve pedir senha
docker run hello-world

# Se pedir sudo, você precisa fazer logout/login
# ou usar temporariamente:
newgrp docker
```

### Teste 2: AppImage
```bash
# Baixar um AppImage de teste (exemplo: Obsidian)
cd ~/Downloads
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/Obsidian-1.5.3.AppImage

# Executar
./Obsidian-1.5.3.AppImage
# Deve abrir normalmente
```

### Teste 3: Bluetooth
```bash
# Verificar se o adaptador está ativo
bluetoothctl show

# Deve mostrar:
# - Powered: yes
# - Discoverable: yes (ou no, dependendo)

# Via GUI
# - Clicar no ícone do Blueman no tray
# - Deve abrir o gerenciador
```

---

## Serviços habilitados

| Serviço    | Status         | Descrição                           |
|------------|----------------|-------------------------------------|
| docker     | enabled        | Docker daemon                       |
| bluetooth  | enabled        | Bluetooth adapter                   |
| blueman    | user-service   | Blueman tray icon (inicia com UI)   |

---

## Troubleshooting

### Docker: "permission denied" ao executar comando
```bash
# Verificar se está no grupo docker
groups
# Deve mostrar: ... docker ...

# Se não aparecer, fazer logout/login
# Ou adicionar manualmente (não recomendado):
sudo usermod -aG docker $USER
newgrp docker
```

### AppImage não executa
```bash
# Verificar se binfmt está ativo
cat /proc/sys/fs/binfmt_misc/appimage-*
# Deve mostrar: enabled

# Testar manualmente
chmod +x arquivo.AppImage
./arquivo.AppImage
```

### Bluetooth não encontra dispositivos
```bash
# Verificar se o adaptador está ligado
rfkill list
# Bluetooth deve estar: Soft blocked: no, Hard blocked: no

# Se estiver bloqueado:
rfkill unblock bluetooth

# Reiniciar o serviço
sudo systemctl restart bluetooth
```

### Blueman não aparece no tray (Qtile)
```bash
# Iniciar manualmente
blueman-applet &

# Se funcionar, adicionar ao autostart do Qtile
# Em ~/.config/qtile/autostart.sh ou equivalente
```

---

## Pacotes úteis relacionados

Você pode adicionar ao `environment.systemPackages` se precisar:

```nix
# Para Docker
docker-compose  # Se quiser versão standalone (já vem com docker)

# Para Bluetooth
bluez-tools     # Ferramentas adicionais de linha de comando
```

---

## Próximos passos

✅ FASE 1 completa  
✅ FASE 2 completa  
⏭️ FASE 3: Pacotes essenciais do workflow
