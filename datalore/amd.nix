{ pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.systemPackages = with pkgs; [ ];
}
