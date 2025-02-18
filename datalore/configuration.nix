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
  cudaPackages = pkgs.cudaPackages_12_4;
in
{
  nixpkgs.overlays = [
    (self: super: {
      cudaPackages = super.cudaPackages // {
        tensorrt_10_3 = super.cudaPackages.tensorrt_10_3.overrideAttrs (oldAttrs: rec {
          dontCheckForBrokenSymlinks = true;
          outputs = [ "out" ];
          fixupPhase = ''
            ${
              oldAttrs.fixupPhase or ""
            } # Remove broken symlinks in the main output
             find $out -type l ! -exec test -e \{} \; -delete || true'';
        });
      };
    })
  ];

  imports = [
    inputs.ucodenix.nixosModules.default
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../global/configuration.nix
    ./amd.nix
    ./nvidia.nix
    ./displaymanager.nix
  ];

  # AMD microcode flake
  services.ucodenix = {
    enable = true;
    cpuModelId = "00A20F12";
  };

  networking.hostName = "datalore";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];

  environment.systemPackages = with pkgs; [
    gcc13
    nvtopPackages.full
    ollama-cuda
    llama-cpp
    cargo
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
    CUDA_PATH = "${cudaPackages.cudatoolkit}";
    CUDA_HOME = "${cudaPackages.cudatoolkit}";
    CUDA_ROOT = "${cudaPackages.cudatoolkit}";
    CUDACXX = "${cudaPackages.cudatoolkit}/bin/nvcc";
    CUDAHOSTCXX = "${pkgs.gcc13}/bin/g++";
    CMAKE_CUDA_HOST_COMPILER = "${pkgs.gcc13}/bin/gcc";
    CUDA_HOST_COMPILER = "${pkgs.gcc13}/bin/gcc";
    CC = "${pkgs.gcc13}/bin/gcc";
    CXX = "${pkgs.gcc13}/bin/g++";
    CUDA_TOOLKIT_ROOT_DIR = "${cudaPackages.cudatoolkit}";
    CUDNN_ROOT = "${cudaPackages.cudnn}";

    # for llama.cpp mostly
    #CMAKE_ARGS = "-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=on";
    #FORCE_CMAKE = lib.mkForce "1";

    # Extend PATH
    PATH = [
      "${cudaPackages.cudatoolkit}/bin"
    ];

    # Set library paths
    LD_LIBRARY_PATH = [
      "${nvidia_driver}/lib"
      "${cudaPackages.nccl}/lib"
      "${cudaPackages.cudatoolkit}/lib"
      "${cudaPackages.cudnn}/lib"
      "${cudaPackages.tensorrt}/lib"
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    LIBRARY_PATH = [
      "${nvidia_driver}/lib"
      "${cudaPackages.nccl}/lib"
      "${cudaPackages.cudatoolkit}/lib"
      "${cudaPackages.cudnn}/lib"
      "${cudaPackages.tensorrt}/lib"
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    CPATH = [
      "${cudaPackages.nccl}/include"
      "${cudaPackages.cudatoolkit}/include"
      "${cudaPackages.cudnn}/include"
      "${cudaPackages.tensorrt}/include"
      "${pkgs.amd-blis}/include"
      "${pkgs.amd-libflame}/include"
    ];
  };

  system.stateVersion = "23.11";
}

