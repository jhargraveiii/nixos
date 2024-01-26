{ config, pkgs, inputs, username,
  gitUsername, gitEmail, gtkThemeFromScheme,
  theme, ... }:

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
        status = {
          symbol = "[x](bold red) ";
        };
        sudo = {
          symbol = "sudo ";
        };
        username = {
          style_user = "green bold";
          style_root = "red bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = true;
        };
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
    libsForQt5.qt5.qtwayland blueman
    hyprland-protocols hyprpaper neofetch lolcat git-cola cmatrix firefox btop libvirt
    polkit_gnome grim slurp lm_sensors unzip unrar gnome.file-roller
    libnotify swaynotificationcenter rofi-wayland imv v4l-utils
    ydotool wl-clipboard socat lsd pkg-config transmission-gtk mpv
    meson gnumake ant maven jetbrains.idea-ultimate slack ungoogled-chromium 
    pavucontrol material-icons thunderbird zathura python3 appimage-run
    pulseaudio wlogout networkmanager networkmanagerapplet
    microsoft-edge appimage-run cliphist swaylock swayidle wl-clipboard wlsunset
    meld openjdk11 openvpn libreoffice-qt hunspell hunspellDicts.en_US
    # Import Scripts
    (import ../config/scripts/emopicker9000.nix { inherit pkgs; })
    (import ../config/scripts/task-waybar.nix { inherit pkgs; })
    (import ../config/scripts/squirtle.nix { inherit pkgs; })
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

  # Enable & Configure QT
  qt.enable = true;
  qt.platformTheme = "qtct";
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
      gtk-cursor-theme-name=Bibata-Modern-Classic
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
      gtk-application-prefer-dark-theme=1
      gtk-cursor-theme-name=Bibata-Modern-Classic
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
      flake-rebuild="sudo nixos-rebuild switch --flake ~/nixos/#workstation";
      n="nano";
      ls="lsd";
      ll="lsd -l";
      la="lsd -a";
      lal="lsd -al";
      ".."="cd ..";
    };
  };
  home.sessionVariables = {
      M2_COLORS = "true";     
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
      JAVA_HOME = "\${HOME}/.jdks/openjdk11/lib/openjdk";
      NIXPKGS_ALLOW_UNFREE = "1";
      SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
      BROWSER = "chromium";
      EDITOR = "nona";
      TERMINAL = "kitty";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_SCALE_FACTOR = "1";
      MOZ_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      GBM_BACKEND = "nvidia-drm";
      CLUTTER_BACKEND = "wayland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      WLR_RENDERER = "vulkan";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GTK_USE_PORTAL = "1";
      #NIXOS_XDG_OPEN_USE_PORTAL = "1";
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      #XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "Bibata-Modern-Ice";
  };
  programs.home-manager.enable = true;
}
