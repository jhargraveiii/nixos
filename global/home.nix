{ pkgs
, username
, gitUsername
, gitEmail
, ...
}:
{
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Nvidia is used only for compute!!
      allowBroken = true;
      blasSupport = true;
      blasProvider = pkgs.amd-blis;
      lapackSupport = true;
      lapackProvider = pkgs.amd-libflame;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  imports = [
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/neovim.nix
    ../modules/programs/vscode.nix
  ];

  home.packages = with pkgs; [
    slack
    clickup
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    github-copilot-intellij-agent
    nodePackages.vscode-langservers-extracted
    firefox
    librewolf
    thunderbird
    libreoffice
    bleachbit
    hunspell
    hunspellDicts.en_US
    klavaro
    meld
    okteta
    vlc
    insync
    git-cola
    cheese
  ];

  home.file.".jdks/openjdk17".source = pkgs.jdk17;

  # Create XDG Dirs
  xdg = {
    mimeApps = {
      enable = true;
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # global home programs
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # Enable fzf key bindings
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    package = pkgs.gitFull;
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    extraPackages = with pkgs; [
      ffmpegthumbnailer
      mediainfo
      sxiv
      kdePackages.kdeplasma-addons
      kdePackages.okular
    ];
    bookmarks = {
      H = "/home/${username}";
    };
    plugins = {
      mappings = {
        c = "fzcd";
        f = "finder";
        v = "imgview";
        o = "xdg-open";
        t = "trash";
        d = "diffs";
        x = "!chmod +x $nnn";
        q = "preview";
      };
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = { };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "kate";
    BROWSER = "firefox";
    TERMINAL = "konsole";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      straker-vpn = "sudo openvpn --config /home/jimh/work/straker_vpn.ovpn";
      straker-office-vpn = "sudo openvpn --config /home/jimh/work/straker_office_vpn.ovpn";
    };
  };
  programs.home-manager.enable = true;
}
