{
  description = "Datalore OS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # User Variables
      username = "jimh";
      gitUsername = "Jim Hargrave";
      gitEmail = "jim.hargrave@strakergroup.com";
      theLocale = "en_US.UTF-8";
      theTimezone = "America/Denver";
      theKBDLayout = "us";
      flakeDir = "/home/${username}/nixos";
      wallpaperDir = "/home/${username}/Pictures/Wallpapers";
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      # Your custom packages and modifications, exported as overlays
      #overlays = import ./modules/overlays { inherit inputs pkgs; };

      nixosConfigurations = {

        "datalore" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit outputs;
            inherit theKBDLayout;
            inherit username;
            inherit gitUsername;
            inherit gitEmail;
            inherit theLocale;
            inherit theTimezone;
          };
          modules = [
            ./datalore/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit system;
                inherit theKBDLayout;
                inherit wallpaperDir;
                inherit outputs;
                inherit flakeDir;
                inherit gitUsername;
                inherit gitEmail;
                inherit inputs;
              };
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./datalore/home.nix;
            }
          ];
        };

        "laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit outputs;
            inherit theKBDLayout;
            inherit username;
            inherit gitUsername;
            inherit gitEmail;
            inherit theLocale;
            inherit theTimezone;
          };
          modules = [
            ./laptop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit system;
                inherit theKBDLayout;
                inherit wallpaperDir;
                inherit outputs;
                inherit flakeDir;
                inherit gitUsername;
                inherit gitEmail;
                inherit inputs;
              };
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./laptop/home.nix;
            }
          ];
        };

      };
    };
}
