{
  config,
  pkgs,
  lib,
  ...
}:

let
  cudaEnv = rec {
    # CUDA Paths
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_HOME = CUDA_PATH;
    CUDA_ROOT = CUDA_PATH;
    CUDA_BIN_PATH = "${CUDA_PATH}/bin";
    CUDACXX = "${CUDA_PATH}/bin/nvcc";
    CUDAHOSTCXX = "${pkgs.gcc}/bin/g++";
    CUDA_TOOLKIT_ROOT_DIR = CUDA_PATH;

    # LD_LIBRARY_PATH and other CUDA-related paths
    CUDA_LD_LIBRARY_PATH = lib.makeLibraryPath [
      "${CUDA_PATH}/lib64"
      "${pkgs.cudaPackages.cudnn}/lib"
      "${pkgs.cudaPackages.cutensor}/lib"
      "${pkgs.cudaPackages.tensorrt}/lib"
      "${pkgs.cudaPackages.nccl}/lib"
      "${pkgs.cudaPackages.libcublas}/lib"
      "${pkgs.cudaPackages.libcufft}/lib"
      "${pkgs.cudaPackages.libcurand}/lib"
      "${pkgs.cudaPackages.libcusolver}/lib"
      "${pkgs.cudaPackages.libcusparse}/lib"
      "${pkgs.cudaPackages.libcufile}/lib"
      "${pkgs.cudaPackages.libnpp}/lib"
      "${pkgs.cudaPackages.libnvjpeg}/lib"
      "${pkgs.cudaPackages.libnvjitlink}/lib"
    ];

    # Flags for compiling and linking CUDA code
    EXTRA_CUDA_LDFLAGS = "-L${CUDA_PATH}/lib64";
    EXTRA_CUDA_CCFLAGS = "-I${CUDA_PATH}/include";
  };
in
{
  inherit cudaEnv;

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
    # NVIDIA utilities
    nvtopPackages.full

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

    # Additional CUDA-related tools
    cudaPackages.nsight_systems
    cudaPackages.nsight_compute
  ];

  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = pkgs.cudaPackages.nvidia_driver;
  };
}
