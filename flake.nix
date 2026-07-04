{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      # User Variables
      username = "jimh";
      gitUsername = "Jim Hargrave";
      gitEmail = "jim.hargrave@strakergroup.com";
      theLocale = "en_US.UTF-8";
      theTimezone = "America/Denver";
      theKBDLayout = "us";
      flakeDir = "/home/${username}/nixos";
      wallpaperDir = "/home/${username}/Pictures/Wallpapers";

      commonSpecialArgs = {
        inherit system inputs outputs theKBDLayout username
                gitUsername gitEmail theLocale theTimezone pkgs-stable;
      };

      commonHomeManagerArgs = {
        inherit username system theKBDLayout wallpaperDir outputs
                flakeDir gitUsername gitEmail inputs pkgs-stable;
      };

      mkHost = hostDir: nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = [
          ./${hostDir}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = commonHomeManagerArgs;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./${hostDir}/home.nix;
          }
        ];
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      nixosConfigurations = {
        "datalore" = mkHost "datalore";
        "laptop" = mkHost "laptop";
      };
    };
}
