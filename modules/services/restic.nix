{ config, lib, pkgs, ... }:

let
  # Restic configuration
  repository = "${config.home.homeDirectory}/restic-repo";    
  excludes = [ 
    ".cache"
    ".tmp"
    ".Trash"
    "${config.home.homeDirectory}/restic-repo"
    repository
  ];
in
{
  # Backup timer
  systemd.user.timers.restic-backup-timer = {
    Unit = {  
      Description = "Run restic backups hourly";
    };
    
    Timer = {
      OnBootSec = "20min";
      OnUnitActiveSec = "1h";    
    };
    
    Install = {
      WantedBy = [ "timers.target" ];  
    };
  };

 # Backup service
systemd.user.services.restic-backup = {
  Service = {
    Type = "oneshot";
    Environment = [ "RESTIC_REPOSITORY=${repository}" "RESTIC_PASSWORD=/etc/nixos/restic-password" ];
    ExecStart = ''
        ${pkgs.restic}/bin/restic backup ${lib.concatMapStrings (s: " " + s) excludes}
    '';
    ExecStartPost = ''
        ${pkgs.restic}/bin/restic forget --prune --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75
    '';
  };
 };
} 