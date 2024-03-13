{
  description = "Datalore OS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ollama = {
      url = "github:abysssol/ollama-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      ollama-cuda = inputs.ollama.packages.${system}.cuda;
  
      # User Variables
      hostname = "datalore";
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
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      # Your custom packages and modifications, exported as overlays
      overlays = import ./modules/overlays { inherit inputs; };
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system; inherit inputs; inherit outputs; inherit ollama-cuda;
            inherit theKBDLayout; inherit username; inherit hostname; inherit gitUsername;
            inherit gitEmail; inherit theLocale; inherit theTimezone;
          };
          modules = [
            ./workstation/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username; inherit system;
                inherit theKBDLayout; inherit wallpaperDir; inherit outputs;
                inherit flakeDir; inherit gitUsername; inherit gitEmail; inherit inputs;
              };
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./workstation/home.nix;
            }
          ];
        };
      };
    };
}
