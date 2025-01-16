{ pkgs, lib, ... }:
{
   nixpkgs.config = {
    rocmSupport = true;
    #rocmVersion = "4.5.0";
    #rocmCapabilities = [ "gfx90a" ];
    rocmPackages = pkgs.rocmPackages;
  };

  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
}
