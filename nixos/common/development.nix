# Development tools and workflow packages
# Languages, cloud tools, IDEs, databases, containers

{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # Limpeza periódica automática (timer systemd docker-prune.service).
    # Evita acúmulo de imagens/containers/redes não usados enchendo o disco.
    autoPrune = {
      enable = true;
      dates = "weekly";      # calendário systemd; troque p/ "daily" se acumular rápido
      flags = [ "--all" ];   # remove imagens não usadas (não só dangling). NÃO mexe em volumes.
    };
  };

  # Enable AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true;  # Allows running AppImages like regular executables
  };

  # Development packages
  environment.systemPackages = with pkgs; [
    # === Languages & Runtimes ===
    
    # Node.js ecosystem
    nodejs_22           # Node.js LTS
    pnpm                # Fast package manager
    # npx comes with nodejs
    
    # Python
    python3
    python3Packages.pip
    uv                  # Fast Python package installer
    
    # Java
    jre                 # Java Runtime
    
    # === Cloud & Infrastructure ===
    
    google-cloud-sdk    # gcloud CLI
    kubectl             # Kubernetes CLI
    kubernetes-helm     # Helm package manager
    (terraform.overrideAttrs (oldAttrs: {
      doCheck = false;  # Skip tests to speed up build
    }))
    
    # === Development Tools ===
    
    # IDEs & Editors
    vscode              # Visual Studio Code
    opencode            # OpenCode AI assistant
    claude-code         # Claude Code (Anthropic's AI coding assistant)
    lmstudio            # GUI para rodar LLMs locais (substitui AppImage em ~/bin)

    # API Testing
    postman             # API testing
    insomnia            # API client alternative
    bruno               # API client offline-first (substitui AppImage em ~/bin)
    yaak                # API client (substitui AppImage em ~/bin)
    httpie              # HTTP client CLI
    
    # Database tools
    dbeaver-bin         # Universal database manager
    supabase-cli        # supabase CLI
    
    # === Diagram & Documentation ===
    
    mermaid-cli         # Mermaid diagrams
    plantuml            # PlantUML diagrams
    drawio              # Editor de diagramas draw.io (substitui AppImage em ~/bin)
    graphviz            # Graph visualization (PlantUML dependency)
    pandoc              # Universal document converter
    languagetool        # Corretor gramatical (substitui LanguageTool-4.3 em ~/bin)

    
    # === CLI Development Tools ===
    
    # Data processing
    yq-go               # YAML/JSON processor
    q-text-as-data      # Query CSV with SQL
    csvkit              # CSV manipulation
    
    # Search & analysis
    silver-searcher     # ag - fast code search
    cloc                # Count lines of code
    
    # Shell & scripting
    shellcheck          # Shell script linter
    entr                # Run commands on file changes
    
    # X11 automation
    xdotool             # X11 automation
    
    # Code formatters
    stylua              # Lua formatter (for neovim)
    
    # Audio manipulation
    sox                 # Sound processing CLI
    
    # Utilities
    trash-cli           # Safe rm alternative
    pamtester           # PAM authentication tester
    gpick               # Color picker
  ];
}
