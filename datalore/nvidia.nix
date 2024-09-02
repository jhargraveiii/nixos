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

  environment.systemPackages = with pkgs; [
    # NVIDIA utilities
    nvtopPackages.nvidia

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

  #hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = pkgs.cudaPackages.nvidia_driver;
  };
}
