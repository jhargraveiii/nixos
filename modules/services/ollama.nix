{ pkgs, lib, buildEnv, ... }:
let
  ollamaOptimized = pkgs.ollama.overrideAttrs (oldAttrs: rec {
    preBuild = ''
      # disable uses of `git`, since nix removes the git directory
      export OLLAMA_SKIP_PATCHING=true
      export CUDA_NVCC_FLAGS="-O3 --gpu-architecture=sm_89 --gpu-code=sm_89 --use_fast_math --ftz=true --prec-div=false --prec-sqrt=false"
      export CXXFLAGS="-march=native -mtune=native -O3 -ffast-math -flto -funroll-loops"
      export COMMON_CMAKE_DEFS='-DCMAKE_CXX_FLAGS="-march=native -mtune=native -O3 -ffast-math -flto -funroll-loops" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_FLAGS="--expt-relaxed-constexpr -use_fast_math" -DCMAKE_CUDA_ARCHITECTURES=89 -DCMAKE_POSITION_INDEPENDENT_CODE=on -DLLAMA_NATIVE=on -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_FMA=on -DLLAMA_F16C=on'
      # build llama.cpp libraries for ollama
      go generate ./...
    '';
    NIX_LDFLAGS = "-flto";
    NIX_CFLAGS_COMPILE = toString [
      "-O3"
      "-march=native"
      "-mtune=native"
      "-ffast-math"
      "-funroll-loops"
    ];
  });
in {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  environment.systemPackages = with pkgs; [ ollamaOptimized ];

  services.ollama = {
    enable = true;
    package = ollamaOptimized;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
