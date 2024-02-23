{ pkgs, theKBDLayout, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.cudnnSupport = true;
  services.xserver = {
    enable = true;
    xkb.layout = "${theKBDLayout}";
    xkb.variant = "";
    libinput.enable = true;
    videoDrivers = [
      "nvidia"
    ];
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
      theme = "tokyo-night-sddm";
    };
    config = ''
      Section "Device"
          Identifier "nvidia"
          Driver "nvidia"
          BusID "PCI:10:0:0"
          #Option "RenderAccel" "true"
          Option "EnablePageFlip" "True"
          Option "XAANoOffscreenPixmaps" "true"
          #Option "AddARGBGLXVisuals" "true"
          Option "DisableGLXRootClipping" "true"
          #Option "DamageEvents" "true"
          Option "AllowGLXWithComposite" "true"
          # Caution
          Option "TripleBuffer" "true"
          #Option "AccelMethod" "EXA"
          #Option "MigrationHeuristic" "greedy"
          #Option "AccelDFS" "true"
          #Option "EnablePageFlip" "true"
      EndSection
    '';
    screenSection = ''
      Option "AllowEmptyInitialConfiguration" "true"
      Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    '';
    deviceSection = '' 
    '';
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

