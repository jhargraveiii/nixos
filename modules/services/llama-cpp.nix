{ pkgs, lib, buildEnv, ... }:
let llamaOptimized = pkgs.callPackage ../../packages/ollama/llama-cpp.nix { };
in {
  environment.systemPackages = with pkgs; [ llamaOptimized ];
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  services.llama-cpp = {
    enable = false;
    package = llamaOptimized;
    extraFlags = [ ];
    model = "/home/jimh/DATA2/models/Phi-3-mini-4k-instruct-q4.gguf";
  };
}
