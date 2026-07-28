# FASE 1: Rede + Syncthing + SSH ✅

## O que foi configurado

### 1. Avahi (mDNS) - Acesso via `navi.local`
```nix
services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  publish = {
    enable = true;      # Anuncia serviços na rede
    addresses = true;   # Anuncia endereço IP
    workstation = true; # Anuncia como workstation
  };
};
```

**O que isso faz:**
- Permite acessar a máquina via `navi.local` de qualquer dispositivo na rede
- Anuncia automaticamente os serviços disponíveis

---

### 2. SSH - Acesso remoto seguro
```nix
services.openssh = {
  enable = true;
  openFirewall = true;
  settings = {
    PasswordAuthentication = true;
    PermitRootLogin = "no";
    AllowUsers = [ "cawal" ];
    MaxAuthTries = 3;
  };
};
```

**O que isso faz:**
- SSH server ativo e seguro
- Apenas usuário `cawal` pode fazer login
- Máximo de 3 tentativas de autenticação
- Root login desabilitado

---

### 3. Syncthing - Sincronização de arquivos
```nix
services.syncthing = {
  enable = true;
  user = "cawal";
  dataDir = "/home/cawal/.syncthing";
  configDir = "/home/cawal/.config/syncthing";
  openDefaultPorts = true;        # Portas 22000 (TCP), 21027 (UDP)
  guiAddress = "0.0.0.0:8384";    # UI acessível pela rede
};
```

**O que isso faz:**
- Syncthing rodando como serviço
- Interface web acessível de qualquer lugar na rede
- Portas necessárias abertas no firewall
- Dados em `/home/cawal/.syncthing`

---

## Como aplicar as mudanças

```bash
# 1. Rebuildar o sistema
sudo nixos-rebuild switch

# 2. Verificar se os serviços estão rodando
systemctl status sshd
systemctl status avahi-daemon
systemctl status syncthing@cawal.service
```

---

## Como testar

### Teste 1: Resolução de hostname
```bash
# De outro dispositivo na rede:
ping navi.local
# Deve responder com o IP da máquina
```

### Teste 2: SSH
```bash
# De outro dispositivo na rede:
ssh cawal@navi.local
# Deve conectar normalmente
```

### Teste 3: Syncthing UI
```bash
# No browser de qualquer dispositivo na rede:
http://navi.local:8384
# Deve abrir a interface do Syncthing
```

**Primeira vez no Syncthing:**
1. Acesse `http://navi.local:8384`
2. Configure uma senha (quando solicitado)
3. Essa senha protege o acesso à UI

---

## Portas abertas no firewall

| Serviço    | Porta(s)              | Protocolo | Descrição                    |
|------------|-----------------------|-----------|------------------------------|
| SSH        | 22                    | TCP       | Acesso remoto via SSH        |
| Avahi      | 5353                  | UDP       | Descoberta de serviços mDNS  |
| Syncthing  | 8384                  | TCP       | Interface web                |
| Syncthing  | 22000                 | TCP       | Sincronização de arquivos    |
| Syncthing  | 21027                 | UDP       | Descoberta de dispositivos   |

---

## Troubleshooting

### `navi.local` não resolve
```bash
# Verificar se avahi está rodando
systemctl status avahi-daemon

# Reiniciar avahi
sudo systemctl restart avahi-daemon

# Testar descoberta mDNS
avahi-browse -a
```

### Syncthing UI não carrega
```bash
# Verificar se o serviço está rodando
systemctl status syncthing@cawal.service

# Ver logs
journalctl -u syncthing@cawal.service -f

# Reiniciar syncthing
sudo systemctl restart syncthing@cawal.service
```

### SSH não conecta
```bash
# Verificar se SSH está rodando
systemctl status sshd

# Ver logs de autenticação
sudo journalctl -u sshd -f

# Verificar firewall
sudo nix-shell -p iptables --run "iptables -L -n | grep 22"
```

---

## Próximos passos

✅ FASE 1 completa  
⏭️ FASE 2: Docker + AppImage + Bluetooth
