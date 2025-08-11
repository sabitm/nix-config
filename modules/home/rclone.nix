{ config, lib, ... }:
let
  confSecret = config.sops.secrets.rclone.path;
  confSource = config.lib.file.mkOutOfStoreSymlink confSecret;
in 
{
  # Enable rclone
  programs.rclone.enable = true;

  # Config file
  xdg.configFile."rclone/rclone.conf" = {
    source = confSource;
  };
}
