# This file defines overlays
{ inputs, ... }: {
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

  nimble2 = final: prev: {
    nimble = prev.nimble.overrideAttrs (oldAttrs: rec {
      requiredNimVersion = 2;
    });
  };

  cuda = final: prev: {
    cudaPackages = prev.cudaPackages_12_3;
  };
}
