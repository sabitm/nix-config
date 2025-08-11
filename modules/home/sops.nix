{ config, home, myconf, ... }:
let
  # Secret dir
  homeDir = "/home/${myconf.username}";
  secrets = "${homeDir}/nix-secret";
  configHome = "${homeDir}/.config";

  # Rclone
  rclone = {
    key = "";
    format = "ini";
    sopsFile = "${secrets}/rclone/rclone.ini";
  };

  # Youtube-viewer
  yt-viewer = {
    key = "";
    format = "json";
    sopsFile = "${secrets}/youtube-viewer/api.json";
  };
in
{
  # Set default sops secret
  sops.defaultSopsFile = "${secrets}/secrets.yaml";
  # Host ssh key
  sops.age.sshKeyPaths = [ "${homeDir}/.ssh/id_ed25519" ];
  # Age system key file
  sops.age.keyFile = "${configHome}/sops/age/keys.txt";
  # Do not validate sops file
  sops.validateSopsFiles = false;

  # Define secrets
  sops.secrets = {
    rclone = rclone;
    yt-viewer = yt-viewer;
  };
}
