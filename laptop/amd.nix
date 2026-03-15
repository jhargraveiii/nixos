{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      rocmPackages = prev.rocmPackages.overrideScope (rfinal: rprev: {
        gpuTargets = [ "gfx1100" ];
      });
    })
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      rocmPackages.clr.icd
    ];
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    ocl-icd
    vulkan-tools
    clinfo
    # ROCm tools
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    # AMD GPU control GUI
    corectrl
  ];

  # CoreCtrl requires polkit to control GPU without root
  programs.corectrl.enable = true;
  # Enable AMD GPU overdrive for full control
  hardware.amdgpu.overdrive.enable = true;

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
}
