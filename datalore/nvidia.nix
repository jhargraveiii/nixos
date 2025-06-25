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
    CUDA_CACHE_PATH = "/tmp/cuda-cache";
    # Reduce VRAM allocation for display
    __GL_SHADER_DISK_CACHE_PATH = "/tmp";
    __GL_SHADER_DISK_CACHE_SIZE = "100000000"; # 100MB
    # Force compute mode
    NVIDIA_VISIBLE_DEVICES = "all";
    NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
  };

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Enable runtime power management for NVIDIA GPUs
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto"
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
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidia_x11_production;
  };
}
