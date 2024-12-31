{
  pkgs,
  username,
  gitUsername,
  theLocale,
  theTimezone,
  theKBDLayout,
  lib,
  ...
}:
{
  nixpkgs = {
    config = {
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

  imports = [
    ../modules/services/networking.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
  ];

  systemd.enableEmergencyMode = false;
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

  environment.systemPackages = with pkgs; [
    openvpn
    jdk21
    nil
    shellcheck
    vale
    hadolint
    yamllint
    cppcheck
    protolint
    pylint
    ruff-lsp
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
    lshw
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
    irqbalance

    # KDE Applications
    kdePackages.kcalc
    kdePackages.kalgebra
    kdePackages.partitionmanager
    kdePackages.isoimagewriter
    kdePackages.filelight
    kdePackages.kcharselect
    kdePackages.kup
    kdePackages.baloo
    kdePackages.baloo-widgets
    kdePackages.milou
    kdePackages.kcoreaddons
    kdePackages.kirigami
    kdePackages.kirigami-addons
    kdePackages.kirigami-gallery
    kdePackages.plasma-workspace

    gnome-firmware
    nix-index
    cargo
    zip
    bup
    qt6.qtwayland
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
    font-awesome
    symbola
    xorg.fontadobe100dpi
    xorg.fontadobeutopia100dpi
    noto-fonts-color-emoji
    noto-fonts-emoji
    noto-fonts-cjk-sans
  ];

  # global hardware settings
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

  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;

  # global services
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

  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "rtprio";
      type = "-";
      value = 99;
    }
  ];

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
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

  security.pam.services._1password = {};
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

  # Updated environment variables
  environment.sessionVariables = {
    # Other environment variables
    SSH_AUTH_SOCK= "~/.1password/agent.sock";
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
    JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "/home/${username}/.local/share/scriptdeps";
    CMAKE_ARGS = "-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=on";
    FORCE_CMAKE = 1;
  };
}
