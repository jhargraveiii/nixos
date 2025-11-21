{ pkgs, theKBDLayout, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.libinput = {
    enable = true;
  };
  services.xserver.xkb.layout = theKBDLayout;


  # Load AMD first, then NVIDIA!!!
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  services.displayManager = {
    defaultSession = "plasma";
    sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };
  };
}
