# NVIDIA GPU configuration
# Proprietary drivers, CUDA support, X11 integration

{ config, pkgs, ... }:

{
  # Enable NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Modesetting is required for most Wayland compositors
    modesetting.enable = true;
    
    # Power management: ligado no fi (laptop) ajuda o suspend/resume da dGPU.
    powerManagement.enable = true;
    # finegrained desliga a dGPU quando ociosa (economiza bateria), mas exige
    # PRIME offload e pode dar instabilidade; deixado desligado por segurança.
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
  # cudnn vive em cudaPackages.* no nixpkgs 26.05 (não é pacote de topo).
  environment.systemPackages = with pkgs; [
    cudatoolkit           # CUDA development toolkit
    cudaPackages.cudnn    # CUDA Deep Neural Network library
  ];
  
  # Gráficos híbridos do fi: iGPU Intel (Core Ultra 7 155H) + NVIDIA RTX 4060.
  # Offload: o iGPU renderiza por padrão (economiza bateria); a dGPU roda sob
  # demanda via `nvidia-offload <app>`. CUDA continua funcionando normalmente.
  # Bus IDs: confirmar no install com `lspci | grep -E 'VGA|3D|Display'`.
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;   # instala o wrapper `nvidia-offload`
    intelBusId = "PCI:0:2:0";          # iGPU Meteor Lake (00:02.0)
    nvidiaBusId = "PCI:1:0:0";         # RTX 4060 (01:00.0)
  };
}
