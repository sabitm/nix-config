{ config, pkgs, myconf, ... }:

{
  imports = [
    ./home/chrome.nix
    ./home/cli.nix
    ./home/fish.nix
    ./home/ghostty.nix
    ./home/git.nix
    ./home/gnome.nix
    ./home/misc.nix
    ./home/navi.nix
    ./home/nixpkgs.nix
    ./home/sops.nix
    ./home/rclone.nix
    ./home/yazi.nix
    ./home/yt-viewer.nix
    ./home/zk.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = myconf.username;
  home.homeDirectory = "/home/${myconf.username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
