{
  pkgs,
  inputs,
  username,
  gitUsername,
  gitEmail,
  flakeDir,
  outputs,
  config,
  ...
}:
let
  nvidia_driver = pkgs.linuxPackages_6_10.nvidia_x11_production;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  imports = [
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/neovim.nix
    ../modules/programs/vscode.nix
  ];

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

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

  nixpkgs = {
    overlays = [ outputs.overlays.cuda-override ];
    # Configure your nixpkgs instance
    config = {
      # Nvidia is used only for compute!!
      allowBroken = true;
      cudaSupport = true;
      cudaVersion = "12.3";
      cudaCapabilities = [ "8.9" ];
      nvidia.acceptLicense = true;
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

  # Install Packages For The User
  home.packages = with pkgs; [
    slack
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    (jetbrains.plugins.addPlugins jetbrains.pycharm-professional [ "github-copilot" ])
    firefox
    _1password
    google-chrome
    thunderbird
    libreoffice
    hunspell
    hunspellDicts.en_US
    klavaro
    meld
    okteta
    vlc
    sddm
    insync
    git-cola
    cheese
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;
  home.file.".jdks/openjdk21".source = pkgs.openjdk21;

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    extraPackages = with pkgs; [
      ffmpegthumbnailer
      mediainfo
      sxiv
      kdeplasma-addons
      okular
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

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
         source $HOME/.oxygen-xml-developer-profile
      fi

      # Set CUDA-related environment variables
      export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
      export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
      export CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
      export CUDACXX="${pkgs.cudaPackages.cudatoolkit}/bin/nvcc"
      export CUDAHOSTCXX="${pkgs.gcc}/bin/g++"
      export CUDA_TOOLKIT_ROOT_DIR="${pkgs.cudaPackages.cudatoolkit}"

      # Set paths
      export PATH="${pkgs.cudaPackages.cudatoolkit}/bin:$PATH"
      export LD_LIBRARY_PATH="${nvidia_driver}/lib:${pkgs.cudaPackages.nccl}/lib:${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn_8_9}/lib:${pkgs.cudaPackages.tensorrt}/lib:${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:$LD_LIBRARY_PATH"
      export LIBRARY_PATH="${nvidia_driver}/lib:${pkgs.cudaPackages.nccl}/lib:${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn_8_9}/lib:${pkgs.cudaPackages.tensorrt}/lib:${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:$LIBRARY_PATH"
      export CPATH="${pkgs.cudaPackages.nccl}/include:${pkgs.cudaPackages.cudatoolkit}/include:${pkgs.cudaPackages.cudnn_8_9}/include:${pkgs.cudaPackages.tensorrt}/include:${pkgs.amd-blis}/include:${pkgs.amd-libflame}/include:$CPATH"

      # Set BLAS-related environment variables
      export BLAS_ROOT="${pkgs.amd-blis}"
      export BLAS_LIBRARIES="${pkgs.amd-blis}/lib/libblis-mt.so"
      export BLAS_INCLUDE_DIRS="${pkgs.amd-blis}/include/blis"
      export LAPACK_ROOT="${pkgs.amd-libflame}"
      export LAPACK_LIBRARIES="${pkgs.amd-libflame}/lib/libflame.so"
      export LAPACK_INCLUDE_DIRS="${pkgs.amd-libflame}/include/flame"
    '';
    bashrcExtra = ''
      # Configure nnn
       export NNN_PLUG='p:preview-tui;l:lastdir'
       export NNN_OPENER="${pkgs.xdg-utils}/bin/xdg-open"
       export NNN_TRASH="1"
       export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
    '';
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';

    shellAliases = {
      flake-check = "nix flake check --verbose --show-trace ${flakeDir}";
      flake-rebuild = "sudo nixos-rebuild switch --keep-going --flake ${flakeDir}#datalore";
      flake-update = "sudo nix flake update ${flakeDir}";
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      less = "most";
      cat = "bat";
      ll = "ls -alF";
      lg = "lazygit";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "kate";
    BROWSER = "firefox";
    TERMINAL = "konsole";
  };
  programs.home-manager.enable = true;
}
