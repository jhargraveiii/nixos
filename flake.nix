{
  description = "Datalore OS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    }; 
    #ollama.url = "github:jhargraveiii/nixos?dir=flakes/ollama";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    # User Variables
    hostname = "datalore";
    username = "jimh";
    gitUsername = "Jim Hargrave";
    gitEmail = "jim.hargrave@strakergroup.com";
    theLocale = "en_US.UTF-8";
    theTimezone = "America/Denver";
    theme = "tokyo-night-storm";
    theKBDLayout = "us";
    flakeDir = "/home/${username}/nixos";

    pkgs = import nixpkgs {
      inherit system;
      config = {
	 allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
	    specialArgs = { inherit system; inherit inputs; 
            inherit theKBDLayout; inherit username; inherit hostname; inherit gitUsername;
            inherit gitEmail; inherit theLocale; inherit theTimezone;
        };
	    modules = [ 
          ./workstation/configuration.nix
          home-manager.nixosModules.home-manager {
	        home-manager.extraSpecialArgs = { inherit username; 
                inherit flakeDir; inherit gitUsername; inherit gitEmail; inherit inputs; inherit theme;
                inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
            };
	        home-manager.useGlobalPkgs = true;
	        home-manager.useUserPackages = true;
	        home-manager.users.${username} = import ./workstation/home.nix;
	      }
	    ];
      };
    };
  };
}
