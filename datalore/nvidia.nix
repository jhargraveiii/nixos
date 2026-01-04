{ config, pkgs, lib, ... }:

let
  nvidia_driver = config.boot.kernelPackages.nvidia_x11_production;
  cuda_packages = pkgs.cudaPackages;
in
{

  hardware.nvidia = {
    # Modesetting is generally required for modern drivers
    modesetting.enable = true;

    # Power management
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use proprietary drivers
    open = false;

    # Settings tool
    nvidiaSettings = false;

    # Package
    package = nvidia_driver;
  };

  # Optimizations for Compute-Only (Save VRAM, improve performance)
  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="RMUseSwI2c=0x01;RMI2cSpeed=100" 
    options nvidia NVreg_EnablePCIeGen3=1
    options nvidia NVreg_UsePageAttributeTable=1
  '';

  # Container Toolkit
  hardware.nvidia-container-toolkit = {
    enable = true;
  };
  
  # Extend timeout for nvidia device detection (fixes boot race condition)
  systemd.services.nvidia-container-toolkit-cdi-generator = {
    serviceConfig = {
      TimeoutStartSec = "30"; # 30 seconds
    };
  };

  # Allow unfree packages for Nvidia
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-persistenced"
        "cuda_cudart"
        "cuda_nvcc"
        "cudatoolkit"
        "cudnn"
        "tensorrt"
        "nccl"
        "magma"
        "cupti"
        # Add other specific unfree packages if needed
      ] || (builtins.parseDrvName (lib.getName pkg)).name == "nvidia-x11";
      
    cudaSupport = true;
  };

  environment.sessionVariables = {
    # CUDA-related environment variables (only for compute)
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_HOME = "${pkgs.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudatoolkit}";
    
    # Optimizations for compute
    CUDA_CACHE_MAXSIZE = "4294967296"; # 4GB Cache
    CUDA_DEVICE_MAX_CONNECTIONS = "32";

    LD_LIBRARY_PATH = [
      "${pkgs.cudatoolkit}/lib"
      "${nvidia_driver}/lib"
      "${cuda_packages.cudnn}/lib"
      "${cuda_packages.tensorrt}/lib"
      "${cuda_packages.nccl}/lib"
    ];
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvtopPackages.full
    ollama-cuda
    llama-cpp
    
    # LLM Training & Inference
    cuda_packages.cudnn
    cuda_packages.tensorrt
    cuda_packages.nccl
    cuda_packages.cuda_nvcc
    cuda_packages.cuda_cudart
    cuda_packages.libcublas
    cuda_packages.libcufft
    cuda_packages.libcurand
    cuda_packages.libcusolver
    cuda_packages.libcusparse
  ];
  
  services.ollama = {
    enable = true;
    user = "ollama-service";
    group = "ollama-service";
  };
}
