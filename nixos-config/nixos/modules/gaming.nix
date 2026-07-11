# Gaming setup
# Steam, game launchers, emulators, gaming utilities

{ config, pkgs, ... }:

{
  # Enable 32-bit graphics drivers (required for many games)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
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
    
    # Wine (for running Windows games/apps)
    wineWowPackages.stable  # Wine with 32-bit and 64-bit support
    winetricks              # Wine configuration helper
  ];
  
  # GameMode service (optimizes system for gaming)
  programs.gamemode.enable = true;
}
