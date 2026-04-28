{ pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    libva-vdpau-driver
  ];

  boot.extraModprobeConfig = ''
    options amdgpu runpm=0
    options amdgpu deep_color=1
  '';

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];

  # Ensure your user is in the video group for GPU access
  users.users.jimh.extraGroups = [ "render" "video" ];
}
