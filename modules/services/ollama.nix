{ pkgs, lib, buildEnv, ... }:
let
  cudatoolkit = pkgs.callPackage ../../packages/cuda-toolkit.nix {
    inherit (pkgs) cudatoolkit;
  };
  ollamaOverride = pkgs.ollama.overrideAttrs (oldAttrs: rec {
    cudaToolkit = pkgs.buildEnv {
      name = "cuda-toolkit";
      ignoreCollisions =
        true; # FIXME: find a cleaner way to do this without ignoring collisions
      paths = [
        cudatoolkit
        pkgs.cudaPackages.cuda_cudart
        pkgs.cudaPackages.cuda_cudart.static
      ];
    };
    preConfigure = ''
      export CUDA_NVCC_FLAGS="-O3 --generate-code arch=compute_86,code=sm_86"
    '';
    NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native";
  });
in {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  environment.systemPackages = with pkgs; [ ollamaOverride cudatoolkit ];

  services.ollama = {
    enable = true;
    package = ollamaOverride;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
