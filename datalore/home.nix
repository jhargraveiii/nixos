{ flakeDir
, ...
}:
{
  home.stateVersion = "23.11";

  imports = [
    ../global/home.nix
  ];

  programs.bash.shellAliases = {
    flake-rebuild = "sudo nixos-rebuild switch --keep-going --flake ${flakeDir}#datalore";
  };
}
