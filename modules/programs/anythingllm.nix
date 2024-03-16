{ config, pkgs, ... }: 
let
  STORAGE_LOCATION = "${config.users.users.jimh.home}/DATA2/anythingllm";
in  
{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      extraPackages = [ pkgs.zfs ];
    };
  };
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.anything-llm = {
    autoStart = true;
    image = "mintplexlabs/anythingllm";
    ports = [ "3001:3001" ];
    # TODO figure out how to create the data directory declaratively
    volumes = [ "${STORAGE_LOCATION}:/app/server/storage" "${STORAGE_LOCATION}/.env:/app/server/.env"];
    extraOptions =
      [ "--privileged" "-e STORAGE_DIR=\"/app/server/storage\"" "--cap-add=SYS_ADMIN"];
    environment = { STORAGE_LOCATION ="${STORAGE_LOCATION}"; };
  };
  # http://localhost:3001
}
