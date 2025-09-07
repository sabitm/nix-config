{ config, pkgs, myconf, ... }:

{
  imports = [
    ./home-min.nix
    ./home/sops.nix
    ./home/rclone.nix
    ./home/yt-viewer.nix
  ];
}
