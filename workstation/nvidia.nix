{ config, pkgs, ... }:
let
  nvidiaOverride =
    config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs
    (oldAttrs: rec { NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; });
in {

  #Nvidia is used only for compute!!
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cuda = true;
    cudVersion = "12.4";
    cudnnSupport = true;
    tensorrtSupport = true;
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    cudaPackages.cudnn
    cudaPackages.tensorrt
  ];
  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = nvidiaOverride;
  };
}
