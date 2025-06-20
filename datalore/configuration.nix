{ pkgs
, username
, gitUsername
, theLocale
, theTimezone
, outputs
, theKBDLayout
, inputs
, system
, lib
, config
, ...
}:
let
  nvidia_driver = pkgs.linuxPackages_6_12.nvidia_x11_production;
  current_cudaPackages = pkgs.cudaPackages_12_8;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../global/configuration.nix
    ./amd.nix
    ./nvidia.nix
    ./displaymanager.nix
  ];

  networking.hostName = "datalore";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    ollama-cuda
    llama-cpp

    # CUDA Toolkit and related packages
    current_cudaPackages.cuda_cudart
    current_cudaPackages.cuda_cupti
    current_cudaPackages.cuda_cccl
    current_cudaPackages.cuda_nvcc
    current_cudaPackages.cuda_nvtx
    current_cudaPackages.cudatoolkit
    current_cudaPackages.cuda_gdb
    current_cudaPackages.cuda_nsight

    # CUDA libraries
    current_cudaPackages.libcublas
    current_cudaPackages.libcufft
    current_cudaPackages.libcurand
    current_cudaPackages.libcusolver
    current_cudaPackages.libcusparse
    current_cudaPackages.libcufile
    current_cudaPackages.libnpp
    current_cudaPackages.libnvjpeg
    current_cudaPackages.libnvjitlink
    current_cudaPackages.cutensor
    current_cudaPackages.cudnn
    current_cudaPackages.nccl
    current_cudaPackages.tensorrt
  ];

  powerManagement = {
    cpuFreqGovernor = "ondemand";
    enable = true;
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.ollama = {
    enable = true;
    user = "ollama-service";
    group = "ollama-service";
    acceleration = "cuda";
  };

  environment.sessionVariables = {
    # CUDA-related environment variables
    CUDA_PATH = "${current_cudaPackages.cudatoolkit}";
    CUDA_HOME = "${current_cudaPackages.cudatoolkit}";
    CUDA_ROOT = "${current_cudaPackages.cudatoolkit}";
    CUDACXX = "${current_cudaPackages.cudatoolkit}/bin/nvcc";
    CUDAHOSTCXX = "${pkgs.gcc}/bin/g++";
    CMAKE_CUDA_HOST_COMPILER = "${pkgs.gcc}/bin/gcc";
    CUDA_HOST_COMPILER = "${pkgs.gcc}/bin/gcc";
    CC = "${pkgs.gcc}/bin/gcc";
    CXX = "${pkgs.gcc}/bin/g++";
    CUDA_TOOLKIT_ROOT_DIR = "${current_cudaPackages.cudatoolkit}";
    CUDNN_ROOT = "${current_cudaPackages.cudnn}";

    # for llama.cpp mostly
    CMAKE_ARGS = "-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=on";
    FORCE_CMAKE = lib.mkForce "1";

    # Extend PATH
    PATH = [
      "${current_cudaPackages.cudatoolkit}/bin"
    ];

    # Set library paths
    LD_LIBRARY_PATH = [
      "${nvidia_driver}/lib"
      "${current_cudaPackages.nccl}/lib"
      "${current_cudaPackages.cudatoolkit}/lib"
      "${current_cudaPackages.cudnn}/lib"
      "${current_cudaPackages.tensorrt}/lib"
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    LIBRARY_PATH = [
      "${nvidia_driver}/lib"
      "${current_cudaPackages.nccl}/lib"
      "${current_cudaPackages.cudatoolkit}/lib"
      "${current_cudaPackages.cudnn}/lib"
      "${current_cudaPackages.tensorrt}/lib"
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    CPATH = [
      "${current_cudaPackages.nccl}/include"
      "${current_cudaPackages.cudatoolkit}/include"
      "${current_cudaPackages.cudnn}/include"
      "${current_cudaPackages.tensorrt}/include"
      "${pkgs.amd-blis}/include"
      "${pkgs.amd-libflame}/include"
    ];
  };

  system.stateVersion = "23.11";
}

