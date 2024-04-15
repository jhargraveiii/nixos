{ pkgs, theKBDLayout, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.xkb.layout = theKBDLayout;

  services.displayManager = {
    enable = true;
    defaultSession = "plasma";
    sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };
  };
}
