# Gaming setup
# Steam, game launchers, emulators, gaming utilities

{ config, pkgs, ... }:

{
  # Enable 32-bit graphics drivers (required for many games)
  # NixOS 24.11+ renomeou hardware.opengl -> hardware.graphics
  # (driSupport foi removido, sempre ligado; driSupport32Bit -> enable32Bit).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;  # Steam Remote Play
    dedicatedServer.openFirewall = true;  # Source Dedicated Server
    
    # Additional Steam configuration
    gamescopeSession.enable = true;  # GameScope for better gaming performance
  };
  
  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    steam
    lutris                # Open source gaming platform (Wine, Proton, etc)
    heroic                # Epic Games & GOG launcher
    
    # Gaming utilities
    mangohud              # Performance overlay (FPS, temps, etc)
    gamemode              # Optimize system performance for games
    protonup-qt           # Proton-GE installer GUI
    
    # Controllers
    antimicrox            # Map controller to keyboard/mouse
    
    # Discord (communication)
    discord
  ];
  
  # RetroArch via Flatpak, não pelo nixpkgs: o build do nixpkgs desliga o Core
  # Downloader e, na 1.22.2, carregar core pelo menu dá SIGSEGV em x_input_state.
  services.flatpak.packages = [ "org.libretro.RetroArch" ];
  services.flatpak.overrides."org.libretro.RetroArch".Context.filesystems = [ "~/Jogos" ];

  # GameMode service (optimizes system for gaming)
  programs.gamemode.enable = true;
}
