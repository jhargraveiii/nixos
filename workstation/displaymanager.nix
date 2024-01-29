{ pkgs, config, theKBDLayout, ... }:

{
   # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
        # cudatoolkit
        # cudatoolkit.lib
    ];
  };

  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.cudnnSupport = true;
  services.xserver = {
    enable = true;
    layout = "${theKBDLayout}";
    xkbVariant = "";
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
          Option "RenderAccel" "true"
          Option "AllowEmptyInitialConfiguration"
          Option "AllowGLXWithComposite" "true"
          Option "XAANoOffscreenPixmaps" "true"
      EndSection
    '';
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
    deviceSection = '' 
    '';
  };

  environment.systemPackages =
let
    sugar = pkgs.callPackage ./sddm-sugar-dark.nix {};
    tokyo-night = pkgs.libsForQt5.callPackage ./sddm-tokyo-night.nix {};
in [ 
    sugar.sddm-sugar-dark # Name: sugar-dark
    tokyo-night # Name: tokyo-night-sddm
    pkgs.libsForQt5.qt5.qtgraphicaleffects
  ];
}

