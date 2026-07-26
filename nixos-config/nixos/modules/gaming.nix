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
    
    # Emulators
    retroarch             # Multi-system emulator frontend
    
    # Gaming utilities
    mangohud              # Performance overlay (FPS, temps, etc)
    gamemode              # Optimize system performance for games
    protonup-qt           # Proton-GE installer GUI
    
    # Controllers
    antimicrox            # Map controller to keyboard/mouse
    
    # Discord (communication)
    discord
  ];
  
  # GameMode service (optimizes system for gaming)
  programs.gamemode.enable = true;
}
