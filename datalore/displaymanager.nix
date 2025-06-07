{ pkgs, theKBDLayout, ... }:

{
  hardware.graphics = {
    enable = true;
  };

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.libinput = {
    enable = true;
  };
  services.xserver.xkb.layout = theKBDLayout;

  services.displayManager = {
    defaultSession = "plasma";
    sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };
  };
}
