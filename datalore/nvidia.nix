{
  config,
  pkgs,
  lib,
  ...
}:
{

  # Nvidia card is used only for compute, not display!!
  
  nixpkgs.config = {
    cudaSupport = true;
    cudaVersion = "12.4";
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  environment.variables = {
    CUDA_CACHE_PATH = "/tmp/cuda-cache";
  };

  services.udev.extraRules = ''
  # Remove NVIDIA USB xHCI Host Controller devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

  # Remove NVIDIA USB Type-C UCSI devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

  # Remove NVIDIA Audio devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

  # Remove NVIDIA VGA/3D controller devices
  #ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
'';

  environment.systemPackages = with pkgs; [
    # CUDA Toolkit and related packages
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cupti
    cudaPackages.cuda_cccl
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_nvtx
    cudaPackages.cuda_sanitizer_api
    cudaPackages.cuda_profiler_api
    cudaPackages.cudatoolkit
    cudaPackages.cuda_gdb
    cudaPackages.cuda_nsight

    # CUDA libraries
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    cudaPackages.libcufile
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    cudaPackages.libnvjitlink
    cudaPackages.cutensor
    cudaPackages.cudnn
    cudaPackages.nccl
    cudaPackages.tensorrt
  ];

  # Enable the NVIDIA driver - but not sure why it is needed for compute only??
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    nvidiaPersistenced = false;
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidia_x11_production;
  };
}
