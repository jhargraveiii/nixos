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
    CUDA_CACHE_MAXSIZE = "4294967296"; # Increase CUDA cache to 4GB
    CUDA_DEVICE_MAX_CONNECTIONS = "32";
    CUDA_AUTO_BOOST_DEFAULT = "0"; # Disable auto boost for deterministic performance
    CUDA_MEMORY_ALLOCATION_POLICY = "COMPACT"; # Prefer compact allocations to reduce VRAM fragmentation
    # Uncomment for debugging:
    # CUDA_LAUNCH_BLOCKING = "1";
    # CUDA_FORCE_PTX_JIT = "1";
    # CUDA_VISIBLE_DEVICES = "0"; # Restrict CUDA to specific GPU(s) if needed
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
    suppressNvidiaDriverAssertion = true;
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

  boot.extraModprobeConfig = ''
    # Coolbits not needed for compute, but harmless
    options nvidia NVreg_Coolbits=0
  '';

  # Ensure both drivers are loaded, AMD for display, NVIDIA for compute
  services.xserver.videoDrivers = [ "nvidia" ];
}
