{ config, lib, pkgs, ... }:

{
  # Enable navi
  programs.navi = {
    enable = true;
    enableFishIntegration = true;
  };

  # Config file
  xdg.dataFile."navi/cheats" = {
    source = ../../data/navi/cheats;
  };
}
