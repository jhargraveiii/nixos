{ config, pkgs, ... }:
{

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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
