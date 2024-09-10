# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  username,
  gitUsername,
  theLocale,
  theTimezone,
  outputs,
  theKBDLayout,
  inputs,
  system,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./amd.nix
    ./displaymanager.nix
    ../modules/services/update-systemd-resolved.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
  ];

  systemd.enableEmergencyMode = false;

  networking.hostName = "datalore_laptop"; # Define your hostname.

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
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "scanner"
      "lp"
      "video"
      "ollama"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      # Replace with your own public key
      "sssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwpk2rfNtxHjaGTucwvBPxcr9D8ly6MXh68/9+VacZy jim.hargrave@strakertranslations.com"
    ];
  };

  nixpkgs = {
    overlays = [ outputs.overlays.cuda-override ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      allowBroken = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      blasSupport = true;
      blasProvider = pkgs.amd-blis;
      lapackSupport = true;
      lapackProvider = pkgs.amd-libflame;
    };
  };

  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
    guest.enable = true;
  };

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    oxygen
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    openvpn
    openjdk11
    nil
    shellcheck
    vale
    hadolint
    yamllint
    cppcheck
    protolint
    pylint
    checkstyle
    gitlint
    checkmake
    cppcheck
    stylelint
    nixpkgs-lint
    nixpkgs-fmt
    protobuf
    statix
    taplo
    jq
    jsonfmt
    deno
    go
    gh
    most
    bat
    tldr
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
    fastfetch
    btop
    lm_sensors
    unzip
    unrar
    libnotify
    lsd
    lshw
    pkg-config
    gnumake
    cmake
    clang
    gcc
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
    vulkan-tools
    wayland-utils
    fwupd
    lazygit
    wl-clipboard
    dotenv-linter
    shellharden
    amd-blis
    amd-libflame
    aocl-utils
    poetry
    (import ../packages/pixi/package.nix {
      inherit
        lib
        stdenv
        rustPlatform
        fetchFromGitHub
        pkg-config
        libgit2
        openssl
        installShellFiles
        darwin
        testers
        pixi
        ;
    })

    # KDE Applications
    kdePackages.kcalc
    kdePackages.kalgebra
    kdePackages.partitionmanager
    kdePackages.isoimagewriter
    kdePackages.filelight
    kdePackages.kcharselect
    kdePackages.krdc
    kdePackages.wacomtablet
    kdePackages.kup
    kdePackages.ktorrent
    kdePackages.dolphin-plugins
    kdePackages.k3b
    bup
    iio-sensor-proxy
    onboard # On-screen keyboard
    nix-index
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    direnvrcExtra = ''
      export EDITOR=kate
      export VISUAL=kate
    '';
  };

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
    #symbola
    xorg.fontadobe100dpi
    xorg.fontadobeutopia100dpi
    noto-fonts-color-emoji
    noto-fonts-emoji
    noto-fonts-cjk
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.dconf.enable = true;
  programs.mtr.enable = true;
  programs.system-config-printer.enable = true;
  programs.nix-ld.enable = true;

  services.printing = {
    enable = true;
    browsing = true;
    stateless = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
    browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All

      BrowseProtocols all
    '';
  };

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
        deviceUri = "ipp://192.168.50.29/ipp";
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
  
  networking.networkmanager.wifi.powersave = true;
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Scheduler settings
      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;

      # Kernel settings
      NMI_WATCHDOG = 0;

      # Disk power management
      DISK_DEVICES = "mmcblk0p1 nvme0n1p1 nvme0n1p2 nvme0n1p3";
      DISK_IDLE_SECS_ON_AC = 0;
      DISK_IDLE_SECS_ON_BAT = 2;
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";
      SATA_LINKPWR_ON_AC = "max_performance";
      SATA_LINKPWR_ON_BAT = "min_power";
      DISK_IOSCHED = "mq-deadline mq-deadline";

      # PCI Express settings
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";

      # Wi-Fi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # Wake-on-LAN
      WOL_DISABLE = "Y";

      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      # Runtime Power Management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # USB settings
      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "1-1"; # Adjust this if you have issues with specific USB devices
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_PHONE = 1;
      USB_EXCLUDE_PRINTER = 1;

      # Restore device state
      RESTORE_DEVICE_STATE_ON_STARTUP = 0;

      # AMD-specific settings (if available)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.package = pkgs.bluez;
  services.blueman.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.udisks2.enable = true;
  services.tumbler.enable = true;
  system.stateVersion = "24.05"; # Did you read the comment?

  services.dbus.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    631
  ];
  networking.firewall.allowedUDPPorts = [
    631
  ];
  networking.firewall.enable = true;

  # Optimization settings and garbage collection automation
  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/nix/var/cache/ccache";
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 24;
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      allowed-users = [ "*" ];
      require-sigs = true;
      sandbox = true;
      sandbox-fallback = false;
      substituters = [ "https://cache.nixos.org/" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      trusted-users = [ "root" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.sessionVariables.TERMINAL = [ "konsole" ];
  environment.sessionVariables.EDITOR = [ "kate" ];
  environment.sessionVariables.BROWSER = [ "firefox" ];
  environment.sessionVariables.XDG_SESSION_TYPE = [ "wayland" ];
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = [ "1" ];
  environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = [ "wayland" ];
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = [ "1" ];
  environment.sessionVariables.QT_QPA_PLATFORM = [ "wayland" ];
  environment.sessionVariables.QT_QPA_PLATFORMTHEME = [ "qt6ct" ];

  # Set Environment Variables
  environment.variables = {
    HF_HOME = "/home/jimh/DATA2/.cache/huggingface";
    PATH = [ "\${HOME}/oxygenDeveloper" ];
    EDITOR = "kate";
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
