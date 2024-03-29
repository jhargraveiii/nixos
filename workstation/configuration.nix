# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs
, username
, hostname
, gitUsername
, theLocale
, theTimezone
, outputs
, theKBDLayout
, inputs
, system
, ...
}:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./amd.nix
      ./nvidia.nix
      ./displaymanager.nix
      ../modules/programs/appimages.nix
      ../modules/programs/1password.nix
      ../modules/services/restic.nix
      ../modules/services/ollama.nix
      ../modules/services/flatpak.nix
      ../modules/services/open-webui.nix
    ];

  systemd.enableEmergencyMode = false;

  networking.hostName = "${hostname}"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.timeServers = [ "pool.ntp.org" ];
  services.timesyncd.enable = true;

  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "${theTimezone}";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "${theLocale}";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${theLocale}";
    LC_IDENTIFICATION = "${theLocale}";
    LC_MEASUREMENT = "${theLocale}";
    LC_MONETARY = "${theLocale}";
    LC_NAME = "${theLocale}";
    LC_NUMERIC = "${theLocale}";
    LC_PAPER = "${theLocale}";
    LC_TELEPHONE = "${theLocale}";
    LC_TIME = "${theLocale}";
  };

  console.keyMap = "${theKBDLayout}";

  # User account
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "scanner" "lp" "video" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      # Replace with your own public key
      "sssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwpk2rfNtxHjaGTucwvBPxcr9D8ly6MXh68/9+VacZy jim.hargrave@strakertranslations.com"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  users.extraGroups.vboxusers.members = [ "jimh" ];
  virtualisation = {
    virtualbox = {
      host = {
        package = pkgs.virtualbox;
        enable = true;
        enableExtensionPack = true;
      };
      guest.enable = true;
      guest.x11 = true;
    };
  };

  nixpkgs = {
    overlays = [
      # we want to use some packages from unstable so need this overlay
      outputs.overlays.stable-packages
      outputs.overlays.cuda
    ];
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    oxygen
    kate
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    openjdk11
    openvpn
    nil
    gh
    python311Full
    gparted
    most
    bat
    tldr
    ncdu
    ant
    maven
    gradle
    kotlin
    fd
    ripgrep
    silver-searcher
    platinum-searcher
    ack
    lolcat
    neofetch
    btop
    lm_sensors
    unzip
    unrar
    libnotify
    lsd
    lshw
    pkg-config
    gnumake
    nano
    wget
    curl
    gitFull
    libinput
    libinput-gestures
    aha
    pciutils
    lshw
    clinfo
    driversi686Linux.glxinfo
    vulkan-tools
    wayland-utils
    fwupd
    lazygit
    lazydocker
    eza
    wl-clipboard
    blesh
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira
    cooper-hewitt
    ibm-plex
    source-code-pro
    nanum-gothic-coding
    jetbrains-mono
    iosevka
    spleen
    fira-code-symbols
    powerline-fonts
    nerdfonts
    font-awesome
    symbola
    xorg.fontadobe100dpi
    xorg.fontadobeutopia100dpi
    noto-fonts-color-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.dconf.enable = true;
  programs.mtr.enable = true;
  programs.system-config-printer.enable = true;

  services.printing.enable = true;
  services.printing.stateless = true;
  services.printing.drivers = [ pkgs.canon-cups-ufr2 ];
  services.printing.browsing = true;
  services.printing.browsedConf = ''
    BrowseDNSSDSubTypes _cups,_print
    BrowseLocalProtocols all
    BrowseRemoteProtocols all
    CreateIPPPrinterQueues All

    BrowseProtocols all
  '';
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon_MF450_Series";
        location = "Home";
        deviceUri = "ipp://Canon224062/ipp";
        model = "CNRCUPSMF450ZS.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Canon_MF450_Series";
  };

  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.pulseaudio.enable = false;
  sound.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.package = pkgs.bluez;
  services.blueman.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.udisks2.enable = true;
  services.tumbler.enable = true;
  system.stateVersion = "23.11";

  services.dbus.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 631 53 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.enable = true;

  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.etc."bashrc".text = ''
    # Load Blesh for Bash
    if [ -f /run/current-system/sw/bin/blesh-init ]; then
      . /run/current-system/sw/bin/blesh-init
    fi
  '';

  environment.sessionVariables.TERMINAL = [ "kitty" ];

  # Set Environment Variables
  environment.variables = {
    PATH = [
      "\${HOME}/oxygenDeveloper"
    ];
    EDITOR = "nvim";
    _ZO_ECHO = "1";
    M2_COLORS = "true";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JAVA_HOME = "\${HOME}/.jdks/openjdk11/lib/openjdk";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
}
