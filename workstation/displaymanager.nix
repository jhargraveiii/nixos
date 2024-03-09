{ pkgs, theKBDLayout, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "${theKBDLayout}";
    libinput.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };
  };
}

