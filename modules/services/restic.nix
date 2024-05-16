{ username, ... }: {
  services.restic = {
    backups = {
      localbackup = {
        exclude = [
          "/home/jimh/invokeai/*"
          ".Trash"
          ".log"
          ".tmp"
          "/home/${username}/.ollama"
          "/home/${username}/.cache"
          "/home/${username}/BACKUP/*"
          "/home/${username}/DATA2/ollama/*"
          "/home/${username}/DATA2/models/*"
        ];
        initialize = true;
        passwordFile = "/etc/nixos/restic-password";
        paths = [ "/home/${username}" ];
        repository = "/home/${username}/BACKUP/restic-repo";
        timerConfig = { OnBootSec = "3600"; };
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
