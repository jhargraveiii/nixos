{ ... }:
{
  imports = [ ../modules/services/displaymanager.nix ];

  services.iptsd = {
    enable = true;
    config.Touchscreen.DisableOnStylus = true;
    config.Touchscreen.DisableOnPalm = true;
  };
  services.xserver.wacom.enable = true;
  hardware.sensor.iio.enable = true;
}
