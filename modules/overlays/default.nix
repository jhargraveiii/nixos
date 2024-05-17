# This file defines overlays
{ inputs, ... }:{
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
    cudaPackages = prev.cudaPackages_12_3;
  };
}
