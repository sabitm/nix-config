{ config, lib, pkgs, ... }:
let
  confSecret = config.sops.secrets.yt-viewer.path;
  confSource = config.lib.file.mkOutOfStoreSymlink confSecret;
in
{
  # Add packages
  home.packages = with pkgs; [
    perl5Packages.WWWYoutubeViewer
  ];

  # Config file
  xdg.configFile."youtube-viewer/api.json" = {
    source = confSource;
  };
}
