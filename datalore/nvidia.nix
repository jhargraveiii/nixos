{ config, pkgs, ... }:
{

  # Nvidia is used only for compute!!
  nixpkgs.config = {
    cudaSupport = true;
    cudaVersion = "12.4";
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    cudaPackages.cudatoolkit
    cudaPackages.cutensor
    cudaPackages.tensorrt
    cudaPackages.cuda_cudart
    cudaPackages.libcusparse
    cudaPackages.libcublas
    cudaPackages.libcurand
    cudaPackages.libcufft
    cudaPackages.cudnn_8_9
    cudaPackages.libcusolver
    cudaPackages.cuda_cccl
    cudaPackages.cuda_nvcc
    cudaPackages.nccl
  ];

  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
