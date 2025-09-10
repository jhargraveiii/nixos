{ pkgs, lib, ... }:
{
  nixpkgs.config = {
    rocmSupport = true;
    rocmVersion = "4.5.0";
    rocmCapabilities = [ "gfx90a" ];
    rocmPackages = pkgs.rocmPackages;
  };

  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    rocmPackages.clr
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    rocmPackages.rocblas
    rocmPackages.rocfft
    rocmPackages.rocrand
    rocmPackages.rocsolver
    rocmPackages.rocsparse
    rocmPackages.hipcc
    rocmPackages.hipblas
    rocmPackages.hipfft
    rocmPackages.rocgdb
    ocl-icd
    vaapiVdpau
    libva
    libvdpau-va-gl
  ];

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "va_gl";
    ROCM_PATH = "${pkgs.rocmPackages.clr}";
    HIP_PATH = "${pkgs.rocmPackages.hipcc}";
    OPENCL_VENDOR_PATH = "/run/opengl-driver/etc/OpenCL/vendors";
  };
}
