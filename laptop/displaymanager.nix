{ pkgs, theKBDLayout, ... }:

{
  hardware.graphics = {
    enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      accelProfile = "adaptive";
      middleEmulation = true;
      disableWhileTyping = true;
    };
  };
  services.iptsd = {
    enable = true;
    config.Touch.DisableOnStylus = true;
    config.Touch.DisableOnPalm = true;
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
