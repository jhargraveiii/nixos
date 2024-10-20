{ pkgs, theKBDLayout, ... }:

{
  hardware.graphics = {
    enable = true;
  };
 
  services.desktopManager.plasma6.enable = true;
  services.libinput = {
    enable = true;
  };
  services.iptsd = {
    enable = true;
    config.Touchscreen.DisableOnStylus = true;
    config.Touchscreen.DisableOnPalm = true;
  };
  services.xserver.wacom.enable = true;

  hardware.sensor.iio.enable = true;
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
