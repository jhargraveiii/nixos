# This file defines overlays
{ inputs, lib, ... }:
let
  # Function to override package attributes
  overridePackageAttrs = pkg:
    if lib.hasAttr "overrideAttrs" pkg then
      pkg.overrideAttrs (oldAttrs: {
        platformDependent = true;
        preConfigure = ''
          export CUDA_USE_TENSOR_CORES=yes
          export GGML_CUDA_FORCE_MMQ=yes 
          export CFLAGS=" -O3 -march=native -mtune=native"
          export CXXFLAGS=" -O3 -march=native -mtune=native"
          export CUDA_NVCC_FLAGS=" -Xptxas -O3 -arch=sm_89 -code=sm_89 -O3 --use_fast_math -maxrregcount=32  -ftz=true -prec-div=false -prec-sqrt=false"
          export CMAKE_CUDA_FLAGS=" -Xptxas -O3 -arch=sm_89 -code=sm_89 -O3 --use_fast_math -maxrregcount=32 -ftz=true -prec-div=false -prec-sqrt=false"
        '' + oldAttrs.preConfigure or "";
        cudaCompatibilities = [ "8.9" ];
        NIX_CFLAGS_COMPILE = toString [
          "-O3"
          "-march=native"
          "-mtune=native"
          "-ffast-math"
          "-funroll-loops"
        ] + oldAttrs.NIX_CFLAGS_COMPILE or "";
      })
    else
      pkg;
in {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  numerical_amd = final: prev: {
    blas = prev.blas.override { blasProvider = final.amd-blis; };
    lapack = prev.lapack.override { lapackProvider = final.amd-libflame; };
  };

  cuda = final: prev: {
    # Override attributes of packages inside cudaPackages
    cudaPackages =
      lib.mapAttrs (name: pkg: overridePackageAttrs pkg) prev.cudaPackages_12_3;
  };
}
