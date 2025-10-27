{ pkgs
, config
, lib
, host
, username
, ...
}:
{
  services.flatpak.enable = true;

  # Enable NetworkManager-wait-online to ensure network-online.target is reliable
  systemd.services.NetworkManager-wait-online.enable = true;
  
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    after = [ 
      "network-online.target" 
      "NetworkManager-wait-online.service"
      "systemd-resolved.service"
    ];
    wants = [ 
      "network-online.target" 
      "NetworkManager-wait-online.service"
    ];
    path = [ pkgs.flatpak pkgs.curl pkgs.networkmanager ];
    script = ''
      # Wait for network connectivity with retries
      echo "Waiting for network connectivity to add Flathub repository..."
      
      for i in {1..30}; do
        # Check if NetworkManager reports we're connected
        if ${pkgs.networkmanager}/bin/nmcli -t -f STATE general | grep -q "connected"; then
          # Double-check with actual connectivity test
          if ${pkgs.curl}/bin/curl -s --max-time 5 https://flathub.org > /dev/null 2>&1; then
            echo "Network connectivity confirmed, adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            exit 0
          fi
        fi
        echo "Waiting for network connectivity... attempt $i/30"
        sleep 2
      done
      
      echo "Warning: Failed to establish network connectivity after 60 seconds"
      echo "You may need to manually run: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
      exit 1
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "30s";
      StartLimitBurst = 3;
    };
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
