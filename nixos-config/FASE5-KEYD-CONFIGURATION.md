# FASE 5: keyd Configuration ✅

## O que foi configurado

### keyd - Remapeamento de Teclado

keyd é uma ferramenta poderosa para remapear teclas a nível de sistema (funciona em X11, Wayland, TTY, etc).

```nix
services.keyd = {
  enable = true;
  keyboards.default = {
    ids = [ "*" ];  # Aplica para todos os teclados
    settings = { ... };
  };
};
```

**O que mudou:**
- ✅ Antes: configuração via arquivo em `/etc/keyd/default.conf` (gerenciado via stow)
- ✅ Agora: configuração declarativa no `configuration.nix`
- ✅ keyd removido de `systemPackages` (gerenciado via serviço)

---

## Configurações Aplicadas

### 1. Global Settings
```nix
global = {
  macro_timeout = 600;            # Timeout da macro inicial
  macro_repeat_timeout = 50;      # Timeout entre repetições
  layer_indicator = 1;            # LED de Caps Lock acende quando layer ativo
  chord_timeout = 50;             # Timeout para chords
  chord_hold_timeout = 0;         # Tempo para ativar chord
  oneshot_timeout = 0;            # Timeout para oneshot layers
  disable_modifier_guard = 0;     # Previne taps extras de modifiers
  overload_tap_timeout = 200;     # Ignora tap se segurado >200ms
};
```

---

### 2. Main Layer (Camada Principal)

#### Caps Lock → Esc/Nav Layer
```nix
capslock = "overload(nav, esc)";
```

**Comportamento:**
- **Pressionar rapidamente**: Esc
- **Segurar**: Ativa a camada `nav`

**Uso prático:**
- Vim/Neovim: Esc rapidamente sem mover a mão
- Navegação: Segurar Caps Lock + hjkl para navegar

---

#### Space → Meta (quando segurado)
```nix
space = "lettermod(meta, space, 150, 200)";
```

**Comportamento:**
- **Pressionar rapidamente**: Espaço normal
- **Segurar**: Tecla Super/Windows/Meta

**Uso prático:**
- `Space + Enter`: Super+Enter (abrir terminal no Qtile/i3)
- `Space + 1`: Super+1 (workspace 1)
- `Space + f`: Super+f (fullscreen)

**Parâmetros:**
- `150ms`: tempo mínimo para detectar hold
- `200ms`: timeout máximo

---

#### Insert → Shift+Insert
```nix
insert = "S-insert";
```

**Comportamento:**
- Pressionar Insert sempre cola (Shift+Insert) no X11

---

### 3. Nav Layer (Camada de Navegação)

Ativada segurando **Caps Lock**.

```nix
"nav:C" = {
  # Vim-style navigation
  h = "left";      # ←
  j = "down";      # ↓
  k = "up";        # ↑
  l = "right";     # →
  
  # Additional navigation
  u = "home";      # Home
  i = "end";       # End
};
```

**Uso prático:**

| Teclas             | Ação               | Uso                          |
|--------------------|--------------------|------------------------------|
| Caps Lock + h      | Seta esquerda      | Navegar sem sair da home row |
| Caps Lock + j      | Seta baixo         | Navegar sem sair da home row |
| Caps Lock + k      | Seta cima          | Navegar sem sair da home row |
| Caps Lock + l      | Seta direita       | Navegar sem sair da home row |
| Caps Lock + u      | Home               | Ir para início da linha      |
| Caps Lock + i      | End                | Ir para fim da linha         |

**Onde funciona:**
- ✅ Navegação em qualquer aplicativo
- ✅ Formulários web
- ✅ Terminal
- ✅ Editores de texto
- ✅ Navegadores

---

## Como aplicar as mudanças

```bash
# 1. Rebuildar o sistema
sudo nixos-rebuild switch

# 2. Reiniciar o serviço keyd
sudo systemctl restart keyd

# 3. Verificar status
sudo systemctl status keyd
```

---

## Testando a configuração

### Teste 1: Caps Lock como Esc
1. Abrir qualquer editor de texto
2. Pressionar **Caps Lock** rapidamente
3. Deve funcionar como **Esc**

### Teste 2: Caps Lock + hjkl (Navegação)
1. Abrir qualquer editor de texto
2. Digitar várias linhas de texto
3. **Segurar Caps Lock** + pressionar **h/j/k/l**
4. Cursor deve navegar como setas

### Teste 3: Space como Meta
1. No Qtile/i3
2. **Segurar Space** + pressionar **Enter**
3. Deve abrir terminal (como Super+Enter)

### Teste 4: Caps Lock + u/i (Home/End)
1. Digitar uma linha longa
2. **Caps Lock + u** → vai para início
3. **Caps Lock + i** → vai para fim

---

## Debugging

### Ver logs do keyd
```bash
sudo journalctl -u keyd -f
```

### Testar configuração manualmente
```bash
# Ver configuração atual
sudo keyd list

# Monitorar teclas pressionadas
sudo keyd monitor
```

### Recarregar configuração sem reboot
```bash
sudo systemctl reload keyd
# ou
sudo systemctl restart keyd
```

---

## Extensões Futuras (Ideias)

Você pode adicionar mais mapeamentos no futuro:

### Exemplo: Home row modifiers (ASDF JKL;)
```nix
main = {
  a = "lettermod(meta, a, 150, 200)";
  s = "lettermod(alt, s, 150, 200)";
  d = "lettermod(control, d, 150, 200)";
  f = "lettermod(shift, f, 150, 200)";
  
  j = "lettermod(shift, j, 150, 200)";
  k = "lettermod(control, k, 150, 200)";
  l = "lettermod(alt, l, 150, 200)";
  semicolon = "lettermod(meta, semicolon, 150, 200)";
};
```

**Observação:** Comentados no seu config original - adicionar só se quiser.

### Exemplo: Layer de símbolos
```nix
main = {
  tab = "overload(symbols, tab)";
};

"symbols:C" = {
  # Números na home row
  a = "1";
  s = "2";
  d = "3";
  f = "4";
  # etc...
};
```

---

## Arquivos envolvidos

### Antes (Ubuntu com stow)
```
~/.config/keyd/default.conf  # Gerenciado via stow
/etc/keyd/default.conf       # Link simbólico
```

### Agora (NixOS)
```
/etc/nixos/configuration.nix          # Configuração declarativa
/nix/store/.../keyd/...               # Pacote keyd
/etc/systemd/system/keyd.service      # Serviço gerado
/var/lib/keyd/                        # Runtime state
```

**Importante:**
- Não precisa mais do `stow` para keyd
- Não precisa copiar manualmente para `/etc/keyd/`
- Tudo é gerenciado pelo NixOS

---

## Vantagens da abordagem NixOS

| Aspecto              | Antes (stow)       | Agora (NixOS)        |
|----------------------|--------------------|----------------------|
| Configuração         | Arquivo manual     | Declarativo          |
| Aplicar mudanças     | Copiar + reload    | nixos-rebuild switch |
| Rollback             | Manual             | Automático           |
| Portabilidade        | Copiar arquivos    | 1 arquivo .nix       |
| Validação            | Runtime            | Build-time           |

---

## Emergency Exit

Se algo der errado e você ficar "preso" no teclado:

**Atalho de emergência do keyd:**
```
Esc + Backspace + Enter
```

Isso desabilita temporariamente o keyd até reiniciar.

---

## Troubleshooting

### Teclas não respondem como esperado
```bash
# Verificar se keyd está rodando
sudo systemctl status keyd

# Ver eventos em tempo real
sudo keyd monitor

# Reiniciar serviço
sudo systemctl restart keyd
```

### Layer não ativa (LED Caps Lock não acende)
```bash
# Verificar se layer_indicator está funcionando
# Alguns compositors Wayland podem interferir
# Testar no X11 ou TTY

# Ver configuração aplicada
sudo cat /var/lib/keyd/default
```

### Configuração não aplica após rebuild
```bash
# Verificar se houve erros no build
sudo nixos-rebuild switch --show-trace

# Forçar reload
sudo systemctl restart keyd

# Ver logs de erro
sudo journalctl -u keyd -n 50
```

### Caps Lock LED funciona mas navegação não
```bash
# Testar se layer está ativa
sudo keyd monitor
# Segurar Caps Lock e pressionar teclas
# Deve mostrar os códigos corretos

# Verificar sintaxe da configuração
# Reabrir configuration.nix e verificar indentação
```

---

## Próximos passos

✅ FASE 1 completa  
✅ FASE 2 completa  
✅ FASE 3 completa  
✅ FASE 4 completa  
✅ FASE 5 completa  
⏭️ Criar README geral explicando novo workflow NixOS

---

## Referências

- [keyd Documentation](https://github.com/rvaiya/keyd)
- [NixOS keyd module](https://search.nixos.org/options?query=services.keyd)
- Seu arquivo original: `keyd_default/default.conf`
