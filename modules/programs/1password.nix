{ pkgs, config, username, ... }:
{
  # Enable 1password plugins on interactive shell init
  programs.bash.interactiveShellInit = ''
    source /home/${username}/.config/op/plugins.sh
  '';

  # Enable 1password and the CLI
  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "${username}" ];
    };
  };

  # Enable 1password to open with gnomekeyring
  security.pam.services."1password".enableGnomeKeyring = true;
}
