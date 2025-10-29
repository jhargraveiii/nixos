{ pkgs
, config
, lib
, host
, username
, ...
}:
{
  services.flatpak.enable = true;

  # Add Flathub repository - runs once at boot, non-blocking
  systemd.services.flatpak-repo = {
    description = "Add Flathub repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Configure Speech Note overrides - runs after user login
  systemd.user.services.flatpak-speech-note-override = {
    description = "Configure Speech Note flatpak permissions";
    wantedBy = [ "default.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      # Only configure if Speech Note is installed
      if flatpak list --app | grep -q "net.mkiol.SpeechNote"; then
        flatpak override --user net.mkiol.SpeechNote \
          --filesystem=/run/ydotoold \
          --filesystem=/run/ydotoold/socket:rw \
          --device=all \
          --share=network \
          --share=ipc \
          --socket=fallback-x11 \
          --socket=x11 \
          --talk-name=org.freedesktop.Flatpak
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };
}
