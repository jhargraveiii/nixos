{
  description = "A flake for running an SWT GTK app with gsettings-desktop-schemas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gsettings-desktop-schemas
          pkgs.gtk3
          pkgs.swt
          pkgs.webkitgtk
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-user-dirs
          pkgs.gnome.adwaita-icon-theme
        ];

        shellHook = ''
          export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
          export XDG_DATA_DIRS=$GSETTINGS_SCHEMA_DIR:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/:$XDG_DATA_DIRS
          export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.swt}/lib
          export SWT_GTK3=1
        '';
      };
    };
}
