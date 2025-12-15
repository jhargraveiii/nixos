{ pkgs, lib, ... }:
{
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      # ROCm for GPU compute (Ollama acceleration)
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
  ];

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
}
