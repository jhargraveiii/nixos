{ pkgs, ... }:
let
  amdOverride = pkgs.amdvlk.overrideAttrs
    (oldAttrs: rec { NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; });
  rocmOverride = pkgs.pkgs.rocmPackages.clr.icd.overrideAttrs
    (oldAttrs: rec { NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; });
in {
  #Nvidia is used only for compute!!
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  systemd.tmpfiles.rules =
    [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.systemPackages = with pkgs; [ rocmPackages.rocm-smi ];
  # OpenGL
  hardware.opengl = {
    ## amdvlk: an open-source Vulkan driver from AMD
    extraPackages = [ amdOverride rocmOverride ];
  };
}
