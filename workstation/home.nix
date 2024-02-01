{ config, pkgs, inputs, username,
  gitUsername, gitEmail, gtkThemeFromScheme,
  theme, flakeDir, unstable-packages, wallpaperDir, ... }:

{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;

  # Set The Colorscheme
  colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default
    ../config/waybar.nix
    ../config/swaync.nix
    ../config/swaylock.nix
    ../config/hyprland.nix
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/rofi.nix
    ../modules/programs/neofetch.nix
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
      # we want to use some packages from unstable so need this overlay
      unstable-packages
    ];
   };
  # Install Packages For The User
  home.packages = with pkgs; [
    qt5ct libva blueman unstable.slack unstable.gnome-text-editor
    lolcat git-cola btop libvirt
    grim slurp lm_sensors unzip unrar gnome.file-roller
    swaynotificationcenter rofi-wayland imv
    transmission-gtk mpv swww
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate ["github-copilot"])
    gnumake ant maven unstable.chromium 
    pavucontrol unstable.thunderbird zathura python3 appimage-run
    networkmanager networkmanagerapplet
    appimage-run cliphist swaylock swayidle wlsunset
    meld openjdk11 openvpn unstable.libreoffice-qt hunspell hunspellDicts.en_US
    # Import Scripts
    (import ../config/scripts/emopicker9000.nix { inherit pkgs; })
    (import ../config/scripts/task-waybar.nix { inherit pkgs; })
    (import ../config/scripts/squirtle.nix { inherit pkgs; })
    (import ../config/scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir; inherit username; })
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      jnoortheen.nix-ide       
    ];
  };

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
      package = gtkThemeFromScheme {scheme = config.colorScheme;};
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
    gtk4.extraConfig = {
    };
  };

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      # fix for electron apps?
      #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(nix build --print-out-paths --no-link nixpkgs#libGL)/lib
    '';
    initExtra = ''
      neofetch
    '';

    sessionVariables = {
    };

    shellAliases = {
      flake-rebuild="sudo nixos-rebuild switch --flake ${flakeDir}";
      flake-update="sudo nix flake update ${flakeDir}";
      gcCleanup="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      n="nano";
      ls="lsd";
      ll="lsd -l";
      la="lsd -a";
      lal="lsd -al";
      ".."="cd ..";
    };
  };
  home.sessionVariables = {
  };
  programs.home-manager.enable = true;
}
