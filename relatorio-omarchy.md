# Relatório: o que anotei no Omarchy, como funciona e o que dá para levar para o meu NixOS/Qtile/Quickshell

Contexto: Omarchy é a distro do DHH (Arch + Hyprland + Quickshell). Explorei o repositório, compilei
minhas anotações do localreview.nvim, entendi como cada coisa é feita e destaquei o que é reaproveitável
no meu sistema (NixOS + Qtile + Quickshell).

---

## Parte 1 — Minhas anotações, agrupadas por tema

### A. Webapps (o mecanismo que achei "bem legal")
- `bin/omarchy-webapp-install:1` — "poxa, isso é bem legal."
- `manual/25-web-apps.md:1` — "Como o Omarchy gera os webapps? Com o chromium? Tem como fazer um comando fácil como o dele para criar um novo webapp?"
- `manual/25-web-apps.md:3` — dashboardicons.com, "quero olhar depois" (fonte de ícones PNG).
- `manual/25-web-apps.md:47` — quero atalhos para apps do Google, algo como `Super+Shift+g, c/m/a/p...` (keychord).

**Resposta curta:** sim, é Chromium (ou qualquer Chromium-based) em modo `--app=<url>`, que dá a janela sem moldura ("frameless"). Detalhes na Parte 2.

### B. Toggles / atalhos de layout (o toggle que eu tinha no i3)
- `default/hypr/toggles.lua:7-18` — "lembro de um toggle útil que eu tinha no i3; talvez recriar como keychord no qtile."

Os toggles do Omarchy que se parecem com truques de i3:
- `omarchy-hyprland-workspace-layout-toggle` — alterna o layout da workspace (dwindle ↔ scrolling).
- `omarchy-hyprland-window-tiled-fullscreen-toggle` — fullscreen "de verdade" vs. tiled.
- `omarchy-hyprland-window-transparency-toggle` — transparência da janela focada.
- `omarchy-hyprland-window-gaps-toggle` — liga/desliga gaps globalmente.

### C. Shell tools / TUIs que quero instalar
- `manual/19-shell-tools.md:51` (`yt-dlp`) — "quero colocar tb se for pequeno."
- `manual/19-shell-tools.md:57-59` (`try`, de Tobi Lütke) — "quero entender esse aqui": gerencia experimentos de código em diretórios datados em `~/Work/tries`.
- `manual/21-tuis.md:3` (Lazygit) — "seria legal ter esse."
- `manual/21-tuis.md:11` (Lazydocker) — "esse também instalar."
- `manual/21-tuis.md:41` (Cliamp) — player de música retro estilo Winamp, com rádios lo-fi. "Preciso procurar depois." Site: cliamp.stream.

Todos disponíveis no nixpkgs: `yt-dlp`, `lazygit`, `lazydocker`, `dua`, `btop`, `fzf`, `zoxide`, `ripgrep`, `eza`, `fd`, `bat`, `tealdeer` (tldr). `try` e `cliamp` provavelmente não estão empacotados — instalar via script/cargo/flake.

### D. Serviços comerciais
- `manual/24-commercial-apps-services.md:21-23` (Dropbox) — "talvez fosse bom ter o dropbox, ainda tenho pastas lá." No NixOS: `services.dropbox` / pacote `dropbox` + `dropbox-cli`.

### E. Input / trackpad (config que eu tinha e quero refazer)
- `manual/34-keyboard-mouse-trackpad.md:3` — refazer config do trackpad do notebook + trackpad sem fio (multi-toque): gestos de 3 dedos para desktop e rolagem "natural" sempre.

---

## Parte 2 — Como o Omarchy faz (mecanismos que entendi)

### 2.1 Webapps = Chromium `--app` + arquivo `.desktop`

Dois scripts pequenos:

**`omarchy-launch-webapp`** — descobre o browser padrão e roda em modo app:
```bash
browser=$(xdg-settings get default-web-browser)
case $browser in
  google-chrome*|brave*|microsoft-edge*|opera*|vivaldi*|helium*) ;;
  *) browser="chromium.desktop" ;;
esac
exec setsid uwsm-app -- \
  $(sed -n 's/^Exec=\([^ ]*\).*/\1/p' .../applications/$browser | head -1) \
  --app="$1" "${@:2}"
```
O truque é o `--app=<url>` (flag do Chromium/Chrome): abre a URL numa janela dedicada, sem barra de endereços nem abas — o visual de "PWA".

**`omarchy-webapp-install`** — cria um `~/.local/share/applications/<Nome>.desktop` com `Exec=omarchy-launch-webapp <url>` e resolve o ícone com uma cascata inteligente:
1. `apple-touch-icon` extraído do HTML da página (costuma ser 180px+);
2. `/apple-touch-icon.png` no domínio;
3. serviço de favicon do Google (`s2/favicons?...&sz=256`) como último recurso.
Depois roda `gtk-update-icon-cache`. Os hotkeys dos webapps ficam em `~/.config/hypr/bindings.lua`.

### 2.2 Toggles = "flag files" no state dir

`omarchy-toggle <flag> [toggle|on|off]` apenas cria/remove um arquivo vazio em
`~/.local/state/omarchy/toggles/<flag>`. O resto do sistema checa `[[ -f $FLAG ]]`. É um padrão de
estado persistente trivial e sem daemon.

Os toggles de janela usam `hyprctl` diretamente. Ex.: transparência:
```bash
addr=$(hyprctl activewindow -j | jq -r '.address')
hyprctl dispatch setprop "address:$addr" opaque toggle
```
O de layout grava um `hl.workspace_rule(...)` num `.lua` por workspace em
`~/.local/state/omarchy/workspace-layouts/<id>.lua` e aplica com `hyprctl eval`/`keyword` — persiste
entre reloads. Este é o "toggle de layout" mais próximo de um truque de i3.

### 2.3 Theming: UMA `colors.toml` → todos os apps (o coração do sistema)

É exatamente o "algo que coordena todos os apps com o mesmo tema". Arquitetura:

**(a) Paleta única** — `themes/<nome>/colors.toml`:
```toml
mode = "dark"
accent = "#7daea3"
selection = "#504945"
background = "#282828"
dark_background = "#1e1e1e"
foreground = "#d4be98"
red = "#ea6962"; green = "#a9b665"; yellow = "#d8a657"
blue = "#7daea3"; magenta = "#d3869b"; cyan = "#89b482"
# + variantes bright_*, ramps de background/foreground, bordas do hyprland (com gradiente)
```

**(b) Templates por app** — `default/themed/*.tpl`, texto puro com `{{ variavel }}`. Ex. alacritty:
```toml
[colors.primary]
background = "{{ background }}"
foreground = "{{ foreground }}"
[colors.normal]
red = "{{ red }}"
green = "{{ green }}"
```
São **17 apps** cobertos: alacritty, kitty, foot, ghostty, btop, hyprland, neovim, helix, vscode,
obsidian, chromium, claude, gum (CLI), shell (QML do Quickshell), pi, keyboard RGB, picker CSS.

**(c) Renderizador** — `bin/omarchy-theme-set-templates`, **bash puro com `sed`** (nada de gomplate/envsubst):
1. lê a paleta com `omarchy-theme-color --file colors.toml --all` para um array associativo;
2. para cada cor gera até 3 formatos: `{{ key }}`→`#7daea3`, `{{ key_strip }}`→`7daea3`, `{{ key_rgb }}`→`122,162,247`;
3. helpers extras: `{{ mix a b 15% }}` (interpola em AWK) e gradientes do hyprland (`hypr_gradient`/`shell_gradient`/`gradient_start`);
4. monta um script `sed` único e aplica em todos os `.tpl`, escrevendo em um dir de staging atômico.
Templates do usuário (`~/.config/omarchy/themed/*.tpl`) têm precedência; arquivos escritos à mão no tema nunca são sobrescritos.

**(d) Aplicação atômica + reload ao vivo** — `bin/omarchy-theme-set`:
- renderiza em `next-theme/`, faz `mv` atômico para `~/.local/state/omarchy/current/theme/`, grava `theme.name`;
- serializa com `flock` (evita corrida entre trocas simultâneas);
- notifica o Quickshell via IPC (payload base64 de `colors.toml`+`shell.toml`) → **redesenha sem reiniciar**;
- em paralelo, "retinta" os apps por sinais/watchers, cada um do seu jeito:
  - Alacritty: `touch` no arquivo (ele observa mtime);
  - Kitty: `killall -SIGUSR1 kitty`; Ghostty: `SIGUSR2`;
  - Hyprland: `hyprctl reload`; Btop: `pkill -SIGUSR2 btop`;
  - GTK/GNOME: `gsettings` (color-scheme + icon-theme);
  - Neovim/Helix: symlink para `current/theme/*` + file watcher;
- dispara um hook `theme-set` (`~/.config/omarchy/hooks/theme-set*`) para extensões do usuário.

**Fronteira de segurança:** temas clonados de git (têm `.git`) passam por filtro que descarta symlinks
e arquivos "com código" (`*.lua`, configs de terminal, extensão do vscode). Temas escritos pelo
próprio usuário confiam nele e entram inteiros.

---

## Parte 3 — O que levar para NixOS + Qtile + Quickshell (com código)

### 3.1 Theming: duas rotas

**Rota A — nativa do NixOS (recomendada para o "todos os apps no mesmo tema"): Stylix.**
Stylix (build-time, base16) faz exatamente o que o Omarchy faz em runtime: uma paleta → gera config de
terminal, GTK, neovim, btop, etc. Em NixOS é idiomático e reprodutível:
```nix
# flake inputs: stylix.url = "github:danth/stylix";
stylix = {
  enable = true;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  polarity = "dark";
  image = ./wallpaper.png;
};
```
Prós: declarativo, cobre GTK/Qt/terminais/neovim de fábrica. Contra: trocar tema = rebuild (não é
"instantâneo" como o Omarchy). Alternativa mais manual: `nix-colors` (só expõe a paleta; você mapeia).

**Rota B — trocador em runtime, estilo Omarchy (se eu quiser trocar sem rebuild).**
O renderizador do Omarchy é totalmente portável: uma pasta de `.tpl` com `{{ cor }}`, um `colors.toml`,
e um script que faz `sed` e manda os sinais de reload. Dá para copiar `omarchy-theme-set-templates` quase
literalmente e alimentar com as cores geradas pelo `nix-colors` (o melhor dos dois: paleta declarativa,
troca em runtime). Como o Quickshell é o mesmo aqui, o padrão de **IPC com payload base64 → redesenho sem
restart** funciona igual — vale copiar essa ideia do `omarchy-theme-set`.

### 3.2 Webapps no Qtile (o "comando fácil" que pedi)
O mecanismo não depende de Hyprland — é só Chromium + `.desktop`. Um script mínimo reaproveitável:
```bash
#!/usr/bin/env bash
# meu-webapp-install <Nome> <url> [icon]
name="$1"; url="$2"
exec_line="chromium --app=$url"   # ou brave/google-chrome-stable
cat > "$HOME/.local/share/applications/$name.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$exec_line
Terminal=false
Icon=${3:-$name}
StartupNotify=true
EOF
```
Ícones em dashboardicons.com. No Qtile, os atalhos de apps do Google viram um **KeyChord**
(o "Super+Shift+g, c/m/a" que anotei):
```python
from libqtile.config import Key, KeyChord
from libqtile.command import lazy
keys = [
    KeyChord([mod, "shift"], "g", [
        Key([], "c", lazy.spawn("chromium --app=https://calendar.google.com")),
        Key([], "m", lazy.spawn("chromium --app=https://mail.google.com")),
        Key([], "a", lazy.spawn("chromium --app=https://maps.google.com")),
        Key([], "p", lazy.spawn("chromium --app=https://photos.google.com")),
    ]),
]
```

### 3.3 Toggles no Qtile
O padrão "flag file" do Omarchy é trivial de replicar, mas no Qtile muita coisa é estado in-process:
- alternar layout ≈ `lazy.next_layout()` ou `KeyChord` que escolhe layout específico;
- fullscreen "de verdade" ≈ `lazy.window.toggle_fullscreen()`;
- para toggles que precisam persistir entre sessões, o padrão de arquivo vazio em
  `~/.local/state/...` + checagem `os.path.exists()` numa função `@lazy.function` funciona igual.
O que eu tinha no i3 (provavelmente toggle de gaps/layout/scratchpad) mapeia para `KeyChord` + os
`lazy.*` acima. Scratchpad no Qtile = `ScratchPad`/`DropDown` na config de `groups`.

### 3.4 Input / trackpad
No Hyprland o Omarchy usa `input.touchpad.natural_scroll`, `clickfinger_behavior`, `scroll_factor` e
`hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })`. No meu setup (Wayland?
provavelmente não, Qtile é X11), o equivalente é `libinput`:
```nix
services.libinput.touchpad = {
  naturalScrolling = true;
  clickMethod = "clickfinger";
  tapping = true;
};
```
Gestos multi-toque de 3 dedos → trocar workspace: em X11/Qtile usar **libinput-gestures** ou **fusuma**
(mapeiam swipe de 3 dedos para comandos `qtile cmd-obj`). Se eu migrar para Wayland algum dia, o modelo
de gesto declarativo do Hyprland é o mais limpo.

### 3.5 Ferramentas para instalar (nixpkgs)
```nix
environment.systemPackages = with pkgs; [
  yt-dlp lazygit lazydocker dua btop
  fzf zoxide ripgrep eza fd bat tealdeer
];
```
`try` (github.com/tobi/try) e `cliamp` (cliamp.stream): provavelmente fora do nixpkgs — empacotar via
`buildGoModule`/`cargo`/flake próprio, ou rodar direto. Dropbox: `services.dropbox` + `dropbox-cli`.

---

## Trechos de código que vale copiar
1. **Cascata de ícone de webapp** (`omarchy-webapp-install:57-78`) — apple-touch-icon → favicon do Google.
2. **Renderizador de tema por `sed`** (`omarchy-theme-set-templates`) — paleta única → N formatos (`_strip`, `_rgb`, `mix`, gradientes).
3. **Troca atômica + IPC de tema para o Quickshell** (`omarchy-theme-set`) — `flock`, `mv` atômico, redesenho sem restart.
4. **Toggle de layout persistente por workspace** (`omarchy-hyprland-workspace-layout-toggle`) — grava `.lua` por workspace e aplica via `hyprctl eval`.
