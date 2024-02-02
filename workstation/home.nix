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
    ../config/files.nix
    ../modules/desktop/waybar.nix
    ../modules/desktop/swaync.nix
    ../modules/desktop/swaylock.nix
    ../modules/desktop/hyprland.nix
    ../modules/programs/kitty.nix
    ../modules/programs/rofi.nix
    ../modules/programs/neofetch.nix
    ../modules/programs/oxygen.nix
    ../modules/services/restic.nix
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
    unstable.slack unstable.gnome-text-editor
    (unstable.jetbrains.plugins.addPlugins unstable.jetbrains.idea-ultimate ["github-copilot"])
    unstable.git-cola unstable._1password unstable.chromium 
    unstable.thunderbird unstable.libreoffice-qt

    qt5ct libva blueman 
    lolcat btop libvirt
    grim slurp lm_sensors unzip unrar gnome.file-roller
    swaynotificationcenter rofi-wayland imv qimgv
    transmission-gtk mpv swww restic
    gnumake ant maven  
    pavucontrol zathura python3 appimage-run
    networkmanager networkmanagerapplet
    appimage-run cliphist swaylock swayidle wlsunset
    meld openjdk11 openvpn hunspell hunspellDicts.en_US
    # Import Scripts
    (import ../modules/scripts/emopicker9000.nix { inherit pkgs; })
    (import ../modules/scripts/task-waybar.nix { inherit pkgs; })
    (import ../modules/scripts/squirtle.nix { inherit pkgs; })
    (import ../modules/scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir; inherit username; })
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
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
