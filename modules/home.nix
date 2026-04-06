{ config, pkgs, myconf, ... }:

{
  imports = [
    ./base.nix
    ./home/sops.nix
    ./home/rclone.nix
    ./home/yt-viewer.nix
  ];
}
