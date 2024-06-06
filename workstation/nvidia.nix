{ config, pkgs, ... }:
{

  #Nvidia is used only for compute!!
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cudVersion = "12.4";
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [ nvtopPackages.nvidia ];

  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
