{ pkgs, ... }:
{
  #Nvidia is used only for compute!!
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.systemPackages = with pkgs; [ rocmPackages.rocm-smi ];
  # OpenGL
  hardware.graphics = {
    ## amdvlk: an open-source Vulkan driver from AMD
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
}
