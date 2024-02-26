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
, ...
}:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ./displaymanager.nix
      ../modules/programs/1password.nix
      ../modules/services/restic.nix
      ../modules/programs/appimages.nix
      ../modules/programs/flatpak.nix
    ];

  networking.hostName = "${hostname}"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.timeServers = [ "pool.ntp.org" ];
  services.timesyncd.enable = true;

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
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_latest_libre.virtualboxGuestAdditions
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
    material-icons
    nano
    wget
    curl
    git
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

  # Unlock with Swaylock
  security = {
    pam = {
      services = {
        swaylock = {
          fprintAuth = false;
          text = ''
            auth include login
          '';
        };
      };
    };
  };

  programs.dconf.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      xfconf
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
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
  services.blueman.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.gvfs.enable = true;
  services.tumbler.enable = true;
  system.stateVersion = "24.05";

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg = {
    portal = {
      wlr.enable = true;
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal
      ];
    };
  };

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

  # Set Environment Variables
  environment.variables = {
    PATH = [
      "\${HOME}/oxygenDeveloper"
    ];
    EDITOR = "nvim";
    _ZO_ECHO = "1";
    M2_COLORS = "true";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JAVA_HOME = "\${HOME}/.jdks/openjdk11/lib/openjdk";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    MOZ_ENABLE_WAYLAND = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GTK_THEME = "Adwaita:dark";
    __EGL_STREAMS_ENABLE = "1";
  };
}
