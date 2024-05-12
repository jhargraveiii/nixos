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
        export NVCCFLAGS="-Xptxas -O3 -arch=sm_89 -code=sm_89 -O3 --use_fast_math"
      '' + oldAttrs.preConfigure or "";
      cudaCompatibilities = [ "8.9" ];
      NIX_CFLAGS_COMPILE = toString [
        "-O3"
        "-march=native"
        "-mtune=native"
        "-ffast-math"
        "-funroll-loops"
      ] + oldAttrs.NIX_CFLAGS_COMPILE or "";
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
