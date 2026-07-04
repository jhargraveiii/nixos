{ pkgs
, flakeDir
, ...
}:
{
  home.stateVersion = "24.05";

  imports = [
    ../global/home.nix
  ];

  home.packages = with pkgs; [
    unetbootin
  ];

  programs.bash.shellAliases = {
    flake-rebuild = "sudo nixos-rebuild switch --keep-going --flake ${flakeDir}#laptop";
  };
}
