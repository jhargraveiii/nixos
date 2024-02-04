{ config, pkgs, username, ... }:
{
  services.restic = {
    backups = {
      localbackup = {
        exclude = [".Trash" ".log" ".tmp" "/home/*/.cache" "/home/${username}/BACKUP/*"];
        initialize = true;
        passwordFile = "/etc/nixos/restic-password";
        paths = ["/home/${username}"];
        repository = "/home/${username}/BACKUP/restic-repo";
        timerConfig =  {
          OnBootSec = "60";
        };
        pruneOpts = [
          "--keep-daily=7"
          "--keep-weekly=5"
          "--keep-monthly=12"
          "--keep-yearly=75"
        ];
      };
    };
  };
}
