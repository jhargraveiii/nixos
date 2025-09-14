{ config, lib, pkgs, username, ... }:

let
  cfg = config.programs.sttWhisper;
in
{
  options.programs.sttWhisper = {
    enable = lib.mkEnableOption "Install whisper-cpp-vulkan and stt-whisper helper";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      whisper-cpp-vulkan
      pipewire
      (pkgs.writeShellScriptBin "stt-whisper" (
        builtins.readFile ../../bin_scripts/stt-whisper.sh
      ))
    ];
  };
}


