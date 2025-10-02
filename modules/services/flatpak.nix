{ pkgs
, config
, lib
, host
, username
, ...
}:
{
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Configure Speech Note to access ydotool service
  systemd.services.flatpak-speech-note-override = {
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-repo.service" ];
    path = [ pkgs.flatpak ];
    script = ''
      # Grant Speech Note access to ydotool socket and required permissions
      flatpak override --user net.mkiol.SpeechNote \
        --filesystem=/run/ydotoold \
        --filesystem=/run/ydotoold/socket:rw \
        --device=all \
        --share=network \
        --share=ipc \
        --socket=fallback-x11 \
        --socket=x11 \
        --talk-name=org.freedesktop.Flatpak || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "${username}";
    };
  };
}
