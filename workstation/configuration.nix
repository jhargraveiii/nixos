# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, username,
  hostname, gitUsername, theLocale,
  theTimezone, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  boot.extraModulePackages = [ ];

  networking.hostName = "${hostname}"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "${theTimezone}";

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

  # User account
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [];
    uid = 1000;
      openssh.authorizedKeys.keys = [
        # Replace with your own public key
        "sssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwpk2rfNtxHjaGTucwvBPxcr9D8ly6MXh68/9+VacZy jim.hargrave@strakertranslations.com"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "jimh" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    docker-compose nano wget curl git restic linuxKernel.packages.linux_latest_libre.virtualboxGuestAdditions
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira
    cooper-hewitt
    ibm-plex
    jetbrains-mono
    iosevka
    spleen
    fira-code-symbols
    powerline-fonts
    nerdfonts
    font-awesome 
    symbola 
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

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  
  # Docker can also be run rootless
  virtualisation.docker = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "${username}" ];
  };

  # Enable 1password to open with gnomekeyring
  security.pam.services."1password".enableGnomeKeyring = true;

  # List services that you want to enable:
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Hide the mouse cursor when not in use
  services.unclutter = {
    enable = true;
    timeout = 2;
    keystroke = false;
    extraOptions = [ "noevents" ];
  };
  
  services.printing.enable = true;
  services.printing.stateless = true;

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon_MF450_Series";
        location = "Home";
        deviceUri = "ipp://Canon224062/ipp";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Canon_MF450_Series";
  };

  services.flatpak.enable = true;
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
  security.rtkit.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      xfconf
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  
  services.restic.backups = {
    localbackup = {
      exclude = [".Trash" ".log" ".tmp" "/home/*/.cache" "/home/jimh/BACKUP/*"];
      initialize = true;
      passwordFile = "/etc/nixos/restic-password";
      paths = ["/home"];
      repository = "/home/jimh/BACKUP/backup-restic";

      timerConfig =  {
        OnBootSec = "600";
      };
      pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
      ];
    };
  };

  system.stateVersion = "23.11";
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 631 53 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.enable = true;

  environment.localBinInPath = true;

  # Set Environment Variables
  environment.variables={
    PATH = [
        "\${HOME}/.cargo/bin"
        "\${HOME}/oxygenDeveloper"
        "\$/usr/local/bin"
      ];
   M2_COLORS = "true";     
   _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
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
   QT_QPA_PLATFORM = "wayland-egl";
   QT_QPA_PLATFORMTHEME = "gtk2";
   QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
   QT_AUTO_SCREEN_SCALE_FACTOR = "1";
   MOZ_ENABLE_WAYLAND = "1";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
}
