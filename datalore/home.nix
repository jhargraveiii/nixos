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
  nixpkgs = {
    overlays = [ outputs.overlays.cuda-override ];
  };

  home.stateVersion = "23.11";
  imports = [
    ../global/home.nix
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/neovim.nix
    ../modules/programs/vscode.nix
  ];

  # Install Packages For The User
  home.packages =
    with pkgs;
    [
    ];

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
         source $HOME/.oxygen-xml-developer-profile
      fi

      export XDG_RUNTIME_DIR="/run/user/$(id -u)"

      # Set CUDA-related environment variables
      export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
      export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
      export CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
      export CUDACXX="${pkgs.cudaPackages.cudatoolkit}/bin/nvcc"
      export CUDAHOSTCXX="${pkgs.gcc}/bin/g++"
      export CUDA_TOOLKIT_ROOT_DIR="${pkgs.cudaPackages.cudatoolkit}"
      export CUDNN_ROOT="${pkgs.cudaPackages.cudnn_8_9}"

      # for llama.cpp mostly
      export CMAKE_ARGS="-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=on"
      export FORCE_CMAKE=1

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
      straker-vpn = "sudo openvpn --config /home/jimh/work/straker_vpn.ovpn --auth-user-pass /home/jimh/work/auth.txt";
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
}
