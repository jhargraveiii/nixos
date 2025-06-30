{ config
, pkgs
, lib
, ...
}:
{

  # Nvidia card is used only for compute, not display!!

  nixpkgs.config = {
    cudaSupport = true;
    cudaVersion = "12.8";
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  environment.variables = {
  };

  services.udev.extraRules = ''
  '';

  environment.systemPackages = with pkgs; [
    config.hardware.nvidia.package
    nvtopPackages.full
  ];

  # Ensure your user is in the render group for GPU access
  users.users.jimh.extraGroups = [ "render" "video" ];

  hardware.nvidia-container-toolkit = {
    enable = true;
  };

  # NVIDIA driver requires X server video driver declaration to properly initialize
  # kernel modules and create device nodes, even in headless/compute-only mode
  services.xserver = {
    enable = true;
    display = null;
    videoDrivers = [ "nvidia" ];
    # Minimize X server footprint for compute-only use
    displayManager.startx.enable = false;
    autorun = false;
  };
  
  hardware.nvidia = {
    nvidiaPersistenced = true; 
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidia_x11_production;
  };
}
