{ config
, pkgs
, inputs
, username
, gitUsername
, gitEmail
, gtkThemeFromScheme
, theme
, flakeDir
, outputs
, wallpaperDir
, ...
}:

{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  # Set The Colorscheme
  colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    ../config/files.nix
    ../modules/desktop/waybar.nix
    ../modules/desktop/swaync.nix
    ../modules/desktop/swaylock.nix
    ../modules/desktop/hyprland.nix
    ../modules/desktop/swappy.nix
    ../modules/programs/kitty.nix
    ../modules/programs/rofi.nix
    ../modules/programs/neofetch.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/neovim.nix
    ../modules/programs/vscode.nix
    #../modules/secrets
  ];

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = 24;
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.file.".config/xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=wlr;gtk
  '';

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    package = pkgs.gitFull;
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };

  nixpkgs = {
    overlays = [
      # we want to use some packages from stable so need this overlay
      outputs.overlays.stable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Install Packages For The User
  home.packages = with pkgs; [
    slack
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    git-cola
    _1password
    chromium
    thunderbird
    libreoffice-qt
    swaylock
    swayidle
    swww
    wlsunset
    rofi-wayland
    swaynotificationcenter
    wl-clipboard
    qt5.qtwayland
    qt5ct
    sddm
    pulseaudio
    libva
    blueman
    lolcat
    btop
    libvirt
    swappy
    grim
    slurp
    lm_sensors
    unzip
    unrar
    gnome.file-roller
    qimgv
    mpv
    restic
    gnumake
    ant
    maven
    pavucontrol
    zathura
    python3
    appimage-run
    networkmanager
    networkmanagerapplet
    appimage-run
    cliphist
    meld
    openjdk11
    openvpn
    hunspell
    hunspellDicts.en_US
    nil
    # Import Scripts
    (import ../modules/scripts/emopicker9000.nix { inherit pkgs; })
    (import ../modules/scripts/task-waybar.nix { inherit pkgs; })
    (import ../modules/scripts/squirtle.nix { inherit pkgs; })
    (import ../modules/scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir; inherit username; })
    (import ../modules/scripts/web-search.nix { inherit pkgs; })
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;

  # Configure Cursor Theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Theme QT -> GTK
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  gtk = {
    enable = true;
    font = {
      name = "Ubuntu";
      size = 12;
      package = pkgs.ubuntu_font_family;
    };
    theme = {
      name = "${config.colorScheme.slug}";
      package = gtkThemeFromScheme { scheme = config.colorScheme; };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = { };
  };

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
         source $HOME/.oxygen-xml-developer-profile
      fi
    '';
    initExtra = ''
      neofetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';

    sessionVariables = { };

    shellAliases = {
      conda-shell = "NIXPKGS_ALLOW_UNFREE=1 nix develop ${flakeDir}/modules/shells/conda --impure";
      flake-rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}";
      flake-update = "sudo nix flake update ${flakeDir}";
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -a";
      lal = "lsd -al";
      ".." = "cd ..";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = { };
  programs.home-manager.enable = true;
}
