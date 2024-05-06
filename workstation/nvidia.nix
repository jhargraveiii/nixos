{ config, pkgs, ... }:
let
  nvidiaOverride =
    config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs
    (oldAttrs: rec { NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; });
in {

  #Nvidia is used only for compute!!
  nixpkgs.config.allowUnfree = true;

  # Load nvidia driver for Xorg and Wayland
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [ ];
  hardware.nvidia = {
    modesetting.enable = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = nvidiaOverride;
  };
}
