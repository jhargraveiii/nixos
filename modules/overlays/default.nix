# This file defines overlays
{ inputs, lib, ... }:
let
  # Function to override package attributes
  overridePackageAttrs = pkg:
    pkg.overrideAttrs (oldAttrs: {
      platformDependent = true;
      preConfigure = ''
        export CFLAGS="-O3 -march=native -mtune=native -ffast-math -funroll-loops"
        export CXXFLAGS="-O3 -march=native -mtune=native -ffast-math -funroll-loops"
        export COMMON_CMAKE_DEFS='-DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=86 -DCMAKE_POSITION_INDEPENDENT_CODE=on -DLLAMA_NATIVE=on -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_FMA=on -DLLAMA_F16C=on'
      '';
      cudaCompatibilities = [ "12.4" ];
      NIX_CFLAGS_COMPILE = toString [
        "-O3"
        "-march=native"
        "-mtune=native"
        "-ffast-math"
        "-funroll-loops"
      ];
      nvccFlags = "-arch=sm_86 -code=sm_86 -O3 --use_fast_math";
    });
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

  cuda = final: prev: {
    # Override attributes of packages inside cudaPackages
    cudaPackages =
      lib.mapAttrs (name: pkg: overridePackageAttrs pkg) prev.cudaPackages_12_3;
  };
}
