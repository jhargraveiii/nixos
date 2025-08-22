{ pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  # AMD GPU stability improvements for Plasma 6
  boot.extraModprobeConfig = ''
    # AMD GPU stability settings - more conservative
    options amdgpu ppfeaturemask=0xffffffff
    options amdgpu runpm=0
    options amdgpu dpm=1
    options amdgpu audio=0
    options amdgpu gpu_recovery=1
    options amdgpu si_support=1
    options amdgpu cik_support=1
    options amdgpu vm_size=64
    options amdgpu vm_block_size=9
    options amdgpu deep_color=1
    options amdgpu use_drm_dp_mst_aux=1
    options amdgpu dc=1
    options amdgpu freesync=0
    options amdgpu experimental=0
    options amdgpu timeout=10000
    # Fix GPU buffer allocation issues
    options amdgpu lockup_timeout=10000
    options amdgpu compute_timeout=60000
    options amdgpu gfx_timeout=60000
    options amdgpu sdma_timeout=60000
    options amdgpu video_timeout=60000
  '';

  # AMD GPU power management
  services.udev.extraRules = ''
    # AMD GPU power management
    SUBSYSTEM=="pci", ATTR{vendor}=="1002", ATTR{device}=="*", ATTR{power_dpm_force_performance_level}="manual"
    SUBSYSTEM=="pci", ATTR{vendor}=="1002", ATTR{device}=="*", ATTR{pp_dpm_mclk}="*"
    SUBSYSTEM=="pci", ATTR{vendor}=="1002", ATTR{device}=="*", ATTR{pp_dpm_sclk}="*"
  '';

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];
}
