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
  lib,
  config,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./amd.nix
    ./nvidia.nix
    ./displaymanager.nix
    ../modules/services/update-systemd-resolved.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
  ];

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      631
      53
    ];
    allowedUDPPorts = [
      5353
      111
    ];
  };

  systemd.enableEmergencyMode = false;

  networking.hostName = "datalore";

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
    overlays = [
      outputs.overlays.cuda-override
    ];

    # Configure your nixpkgs instance
    config = {
      cudaSupport = true;
      cudaVersion = "12.3";
      cudaCapabilities = [ "8.9" ];
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
    kdePackages.kup
    bup
    kdePackages.baloo
    kdePackages.baloo-widgets
    kdePackages.milou
    nvtopPackages.full
    ollama-cuda
    llama-cpp
    nix-index
    cargo
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    direnvrcExtra = ''
      export EDITOR=nvim
      export VISUAL=nvim
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

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "rtprio";
      type = "-";
      value = 99;
    }
  ];

  hardware.pulseaudio.enable = false;
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
        "gccarch-znver3"
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
    TERMINAL = "konsole";
    EDITOR = "kate";
    BROWSER = "firefox";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";

    HF_HOME = "/home/${username}/DATA2/.cache/huggingface";
    _ZO_ECHO = "1";
    M2_COLORS = "true";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JAVA_HOME = "/home/${username}/.jdks/openjdk11/lib/openjdk";
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "/home/${username}/.local/share/scriptdeps";
    CMAKE_ARGS="-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=on";
    FORCE_CMAKE=1;
    PATH = "${pkgs.cudaPackages.cudatoolkit}/bin:$PATH";
  };
}
