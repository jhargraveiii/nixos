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
    CUDA_CACHE_MAXSIZE = "4294967296";
    CUDA_DEVICE_MAX_CONNECTIONS = "32";
    CUDA_AUTO_BOOST_DEFAULT = "0";
    CUDA_MEMORY_ALLOCATION_POLICY = "COMPACT";
    # Uncomment for debugging or multi-GPU:
    # CUDA_VISIBLE_DEVICES = "0"; # Restrict CUDA to specific GPU(s)
    # NVIDIA_VISIBLE_DEVICES = "all"; # For containers
    # NCCL_DEBUG = "INFO"; # For multi-GPU debugging
    # NCCL_P2P_DISABLE = "1"; # Disable peer-to-peer if needed
    XLA_PYTHON_CLIENT_PREALLOCATE = "false"; # For JAX, disables preallocating all VRAM
    TF_FORCE_GPU_ALLOW_GROWTH = "true"; # For TensorFlow, enables dynamic VRAM allocation
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
    options nvidia NVreg_RestrictProfilingToAdminUsers=0
  '';

  # Ensure both drivers are loaded, AMD for display, NVIDIA for compute
  services.xserver.videoDrivers = [ "nvidia" ];
}
