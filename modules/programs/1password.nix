{ pkgs, config, username, ... }:
{
  environment.systemPackages = with pkgs; [ unstable._1password unstable._1password-gui ];
}
