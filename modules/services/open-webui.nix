{ config, pkgs, ... }: {
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      extraPackages = [ pkgs.zfs ];
    };
  };
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.open-webui = {
    autoStart = true;
    image = "ghcr.io/open-webui/open-webui:main";
    ports = [ "8080:8080" ];
    # TODO figure out how to create the data directory declaratively
    volumes = [ "${config.users.users.jimh.home}/DATA2/open-webui:/app/backend/data" ];
    extraOptions =
      [ "--network=host" ];
    environment = { OLLAMA_BASE_URL = "http://127.0.0.1:11434"; };
  };
}
