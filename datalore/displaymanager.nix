{ pkgs, theKBDLayout, ... }:

{
  hardware.graphics = {
    enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.libinput = {
    enable = true;
  };
  services.xserver.xkb.layout = theKBDLayout;

  environment.sessionVariables = {
    QML2_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    QML_DISABLE_DISK_CACHE = 0;
  };

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
