# NVIDIA GPU configuration
# Proprietary drivers, CUDA support, X11 integration

{ config, pkgs, ... }:

{
  # Enable NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Modesetting is required for most Wayland compositors
    modesetting.enable = true;
    
    # Power management (usually not needed for desktop)
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    
    # Use proprietary driver (better for gaming and CUDA)
    # Set to true for open-source driver
    open = false;
    
    # Enable NVIDIA settings menu
    nvidiaSettings = true;
    
    # Use stable driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # CUDA Toolkit for AI/ML workloads
  environment.systemPackages = with pkgs; [
    cudatoolkit       # CUDA development toolkit
    cudnn             # CUDA Deep Neural Network library
  ];
  
  # Uncomment if using hybrid graphics (laptop with Intel + NVIDIA)
  # You'll need to find the correct bus IDs using: lspci | grep -E 'VGA|3D'
  # 
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   offload.enableOffloadCmd = true;
  #   
  #   # Bus IDs - find with: sudo lshw -c display
  #   intelBusId = "PCI:0:2:0";
  #   nvidiaBusId = "PCI:1:0:0";
  # };
}
