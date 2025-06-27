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
    # Force headless mode and minimize display memory
    __GL_SHADER_DISK_CACHE_PATH = "/tmp";
    __GL_SHADER_DISK_CACHE_SIZE = "100000000"; # 100MB
    __GLX_FORCE_VRAM_MAPPING = "0";
    __GL_THREADED_OPTIMIZATIONS = "0";
    # Force compute mode
    NVIDIA_VISIBLE_DEVICES = "all";
    NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
    # Minimize display memory allocation
    NVIDIA_RESERVED_MEMORY = "128";
    __GL_MaxFramesAllowed = "0";
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
    
    # Ensure compute access for monitoring tools
    KERNEL=="nvidia*", GROUP="render", MODE="0664"
    KERNEL=="nvidiactl", GROUP="render", MODE="0664"
    KERNEL=="nvidia-uvm", GROUP="render", MODE="0664"
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
