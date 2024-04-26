{ pkgs, lib, ... }:
let
 ollamaOverride = pkgs.ollama.overrideAttrs (oldAttrs: rec {
    version = "0.1.32";
    src = pkgs.fetchFromGitHub {
      owner = "jmorganca";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-Ip1zrhgGpeYo2zsN206/x+tcG/bmPJAq4zGatqsucaw="; 
      fetchSubmodules = true;
    };
    NIX_CFLAGS_COMPILE = "-O3 -march=znver3 -mtune=znver3";
    vendorHash = "sha256-Lj7CBvS51RqF63c01cOCgY7BCQeCKGu794qzb/S80C0="; 
  });
in
{
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  environment.systemPackages = with pkgs; [ ollamaOverride ];
  services.ollama = {
    enable = true;
    package = ollamaOverride;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
