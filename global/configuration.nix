{ pkgs
, username
, gitUsername
, theLocale
, theTimezone
, theKBDLayout
, lib
, ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      blasSupport = true;
      blasProvider = pkgs.amd-blis;
      lapackSupport = true;
      lapackProvider = pkgs.amd-libflame;
    };
  };

  nixpkgs.overlays = [
  ];

  imports = [
    ../modules/services/networking.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
    ../modules/services/pia.nix
  ];

  systemd.enableEmergencyMode = false;
  services.timesyncd.enable = true;
  services.fwupd.enable = true;
  services.smartd.enable = true;
  hardware.usbStorage.manageShutdown = true;

  # Set your time zone.
  time.timeZone = "${theTimezone}";
  time.hardwareClockInLocalTime = false;

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
      "piavpn"
      "input"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwpk2rfNtxHjaGTucwvBPxcr9D8ly6MXh68/9+VacZy jim.hargrave@strakertranslations.com"
    ];
  };

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    oxygen
  ];

  environment.systemPackages = with pkgs; [
    openvpn
    jdk21
    nil
    shellcheck
    marksman
    vale
    hadolint
    yamllint
    cppcheck
    protolint
    pylint
    ruff
    checkstyle
    gitlint
    checkmake
    cppcheck
    stylelint
    nixpkgs-lint
    nixpkgs-fmt
    yaml-language-server
    protobuf
    statix
    shfmt
    taplo
    jq
    jsonfmt
    yamlfmt
    go
    gh
    most
    bat
    tldr
    ant
    maven
    fd
    ripgrep
    silver-searcher
    platinum-searcher
    ack
    lolcat
    fastfetch
    btop
    iotop
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
    ccache
    mpi
    nano
    wget
    curl
    gitFull
    git-lfs
    libinput
    libinput-gestures
    aha
    pciutils
    clinfo
    vulkan-tools
    wayland-utils
    fwupd
    lazygit
    wl-clipboard
    dotenv-linter
    shellharden
    aocl-utils
    poetry
    pipenv
    pixi
    mecab
    uv
    pqrs

    # KDE Plasma 6 Wayland essentials
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    wayland
    xwayland
    xkeyboard-config

    # Core KDE Plasma packages
    kdePackages.plasma-workspace
    kdePackages.kwayland
    kdePackages.plasma-desktop
    kdePackages.kwin
    kdePackages.breeze
    kdePackages.systemsettings

    # KDE Applications
    kdePackages.kcalc
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kup
    kdePackages.baloo
    kdePackages.baloo-widgets
    kdePackages.kcoreaddons
    kdePackages.kirigami
    kdePackages.kirigami-addons
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style

    gnome-firmware
    nix-index
    nix-ld
    zip
    bup
    psutils
    brev-cli
    inetutils
    smartmontools

    amd-libflame
    amd-blis
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
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    nerd-fonts.jetbrains-mono
    font-awesome
    symbola
    xorg.fontadobe100dpi
    xorg.fontadobeutopia100dpi
    noto-fonts-color-emoji
    noto-fonts-emoji
    noto-fonts-cjk-sans
  ];

  # Enable network discovery if scanner is network-connected
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # enable pia
  services.pia.enable = true;

  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.sane-airscan
      pkgs.sane-backends
    ];
    disabledDefaultBackends = [ "escl" ];
  };

  # use IPP everywhere for printing
  services.printing = {
    enable = true;
    browsing = true;
    stateless = true;
    webInterface = true;

    browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All
      BrowseProtocols all
    '';
  };

  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
  services.fstrim.enable = true;
  services.fstrim.interval = "weekly";

  services.udev.extraRules = ''
    # Prefer none for NVMe, mq-deadline for SATA SSD, bfq for HDD
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="mmcblk[0-9]", ATTR{queue/scheduler}="mq-deadline"
  '';

  # Keep journal bounded to reduce writes
  services.journald = {
    extraConfig = ''
      Storage=auto
      SystemMaxUse=500M
      RuntimeMaxUse=500M
      MaxRetentionSec=2week
      MaxFileSec=1day
    '';
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.polkit.enable = true;
  services.udisks2.enable = true;
  services.dbus.enable = true;

  # globl programs
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    direnvrcExtra = ''
      export EDITOR=nvim
      export VISUAL=nvim
    '';
  };

  security.pam.services._1password = { };
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      "jimh"
      "root"
    ];
  };

  programs.dconf.enable = true;
  programs.mtr.enable = true;
  programs.system-config-printer.enable = true;
  programs.nix-ld.enable = true;

  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/nix/var/cache/ccache";

  programs.ydotool = {
    enable = true;
    group = "input";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      download-buffer-size = 524288000; # 500 MiB
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 0;
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      allowed-users = [ "root" "${username}" ];
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

  # Updated environment variables
  environment.sessionVariables = {
    #SAL_USE_VCLPLUGIN = "kf5"; # For KDE Plasma 6
    # Other environment variables
    SSH_AUTH_SOCK = "~/.1password/agent.sock";
    TERMINAL = "konsole";
    EDITOR = "kate";
    BROWSER = "firefox";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    HF_HOME = "/home/${username}/DATA2/.cache/huggingface";
    _ZO_ECHO = "1";
    M2_COLORS = "true";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JAVA_HOME = "${pkgs.openjdk21}/lib/openjdk";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "/home/${username}/.local/share/scriptdeps";
  };
}
