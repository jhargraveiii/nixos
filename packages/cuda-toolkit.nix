{ lib, cudatoolkit, gcc12, pkgs, ... }:

cudatoolkit.overrideAttrs (oldAttrs: rec {
  NIX_CFLAGS_COMPILE = toString [ "-O3" "-march=native" "-mtune=native" ];

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ gcc12 ];

  preConfigure = ''
    export CUDA_NVCC_FLAGS="-O3 --generate-code arch=compute_86,code=sm_86"
  '';
})
