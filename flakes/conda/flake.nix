{
  description = "An FHS shell with conda and cuda.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # Conda installs it's packages and environments under this directory
      installationPath = "/home/jimh/.conda";

      # Downloaded Miniconda installer
      minicondaScript = pkgs.stdenv.mkDerivation rec {
        name = "miniconda-${version}";
        version = "latest";
        src = pkgs.fetchurl {
          url = "https://repo.continuum.io/miniconda/Miniconda3-${version}-Linux-x86_64.sh";
          sha256 = "c9ae82568e9665b1105117b4b1e499607d2a920f0aea6f94410e417a0eff1b9c";
        };
        # Nothing to unpack.
        unpackPhase = "true";
        # Rename the file so it's easier to use. The file needs to have .sh ending
        # because the installation script does some checks based on that assumption.
        # However, don't add it under $out/bin/ becase we don't really want to use
        # it within our environment. It is called by "conda-install" defined below.
        installPhase = ''
          mkdir -p $out
          cp $src $out/miniconda.sh
        '';
        # Add executable mode here after the fixup phase so that no patching will be
        # done by nix because we want to use this miniconda installer in the FHS
        # user env.
        fixupPhase = ''
          chmod +x $out/miniconda.sh
        '';
      };

      # Wrap miniconda installer so that it is non-interactive and installs into the
      # path specified by installationPath
      conda = pkgs.runCommand "conda-install"
        { buildInputs = [ pkgs.makeWrapper minicondaScript ]; }
        ''
          mkdir -p $out/bin
          makeWrapper                            \
            ${minicondaScript}/miniconda.sh      \
            $out/bin/conda-install               \
            --add-flags "-p ${installationPath}" \
            --add-flags "-b"
        '';

    in
    {
      devShells.x86_64-linux.default = (pkgs.buildFHSUserEnv {
        name = "conda";
        targetPkgs = pkgs: (
          with pkgs; [
            conda
            autoconf
            binutils
            cudaPackages_12_3.cudatoolkit
            cudaPackages_12_3.libcublas
            curl
            freeglut
            gcc11
            git
            gitRepo
            gnumake
            gnupg
            gperf
            libGLU
            libGL
            libselinux
            linuxKernel.packages.linux_6_6.nvidia_x11_stable_open
            m4
            ncurses5
            procps
            stdenv.cc
            unzip
            util-linux
            wget
            xorg.libICE
            xorg.libSM
            xorg.libX11
            xorg.libXext
            xorg.libXi
            xorg.libXmu
            xorg.libXrandr
            xorg.libXrender
            xorg.libXv
            zlib
          ]
        );
        profile = ''
          # cuda
          export CUDA_PATH=${pkgs.cudaPackages_12_3.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.linuxKernel.packages.linux_6_6.nvidia_x11_stable_open}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxKernel.packages.linux_6_6.nvidia_x11_stable_open}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"

          # conda
          export PATH=${installationPath}/bin:$PATH
          # Paths for gcc if compiling some C sources with pip
          export NIX_CFLAGS_COMPILE="-I${installationPath}/include"
          export NIX_CFLAGS_LINK="-L${installationPath}lib"
          # Some other required environment variables
          export FONTCONFIG_FILE=/etc/fonts/fonts.conf
          export QTCOMPOSE=${pkgs.xorg.libX11}/share/X11/locale
        '';
      }).env;
    };
}
