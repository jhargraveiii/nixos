{ pkgs, inputs, theKBDLayout, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "${theKBDLayout}";
    xkb.variant = "";
    libinput.enable = true;
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
      theme = "tokyo-night-sddm";
    };
  };

  environment.systemPackages =
    let
      sugar = pkgs.callPackage ../modules/desktop/sddm-sugar-dark.nix { };
      tokyo-night = pkgs.libsForQt5.callPackage ../modules/desktop/sddm-tokyo-night.nix { };
    in
    [
      sugar.sddm-sugar-dark # Name: sugar-dark
      tokyo-night # Name: tokyo-night-sddm
      pkgs.libsForQt5.qt5.qtgraphicaleffects
    ];
}

