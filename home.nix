{ config, pkgs, inputs, username,
  gitUsername, gitEmail, gtkThemeFromScheme,
  theme, ... }:

{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  # Set The Colorscheme
  colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./config/waybar.nix
    ./config/swaync.nix
    ./config/swaylock.nix
    ./config/neofetch.nix
    ./config/hyprland.nix
    ./config/kitty.nix
    ./config/rofi.nix
    ./config/vim.nix
    ./config/files.nix
  ];

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = 24;
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
    settings = {
        add_newline = true;
        character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
        };
        git_commit = {
          tag_symbol = " tag ";
        };
        git_status = {
          ahead = ">";
          behind = "<";
          diverged = "<>";
          renamed = "r";
          deleted = "x";
        };
        java = {
          symbol = "java ";
        };
        nix_shell = {
          symbol = "nix ";
        };
        package = {
            disabled = false;
            symbol = "pkg ";
        };
    };
  };

  # Install Packages For The User
  home.packages = with pkgs; [
    neofetch lolcat git-cola cmatrix firefox btop libvirt
    swww polkit_gnome grim slurp lm_sensors unzip unrar gnome.file-roller
    libnotify sway swaynotificationcenter rofi-wayland imv v4l-utils
    ydotool wl-clipboard socat lsd pkg-config transmission-gtk mpv
    meson gnumake ant maven jetbrains.idea-ultimate slack chromium 
    pavucontrol material-icons thunderbird zathura python3 appimage-run
    libreoffice pulseaudio wlogout networkmanagerapplet
    microsoft-edge appimage-run cliphist swaylock swayidle wl-clipboard wlsunset
    meld openjdk11
    # Import Scripts
    (import ./config/scripts/emopicker9000.nix { inherit pkgs; })
    (import ./config/scripts/task-waybar.nix { inherit pkgs; })
    (import ./config/scripts/squirtle.nix { inherit pkgs; })
    (import ./config/scripts/wallsetter.nix { inherit pkgs; })
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;

   programs.vscode = {
     enable = true;
     package = pkgs.vscodium;
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

  # Enable & Configure QT
  qt.enable = true;
  qt.platformTheme = "gtk";
  qt.style.name = "adwaita-dark";
  qt.style.package = pkgs.adwaita-qt;

  # Theme GTK
  gtk = {
    enable = true;
    font = {
      name = "Ubuntu";
      size = 14;
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
      Settings = ''
      gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
      gtk-application-prefer-dark-theme=1
      '';
    };
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
        enable = true;
        createDirectories = true;
    };
  };

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      #  exec Hyprland
      #fi
    '';
    sessionVariables = {
    };

    shellAliases = {
      backup=''restic -r ~/BACKUP/backup-restic --verbose backup ~/ --exclude="/home/jimh/BACKUP/*" --password-file /etc/nixos/restic-password'';
      sn="sudo nano";
      flake-rebuild="sudo nixos-rebuild switch --flake ~/nixos/#workstation";
      n="nano";
      ls="lsd";
      ll="lsd -l";
      la="lsd -a";
      lal="lsd -al";
      ".."="cd ..";
    };
  };

  programs.home-manager.enable = true;
}
