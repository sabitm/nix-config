{ config, pkgs, ... }:

{
  # Enable ghostty
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      adjust-cell-width = "-6%";
      font-family = ''"MesloLGS NF"'';
      font-size = 12;
      theme = "GruvboxDarkHard";
      window-decoration = "none";
      gtk-titlebar = false;
    };
  };
}

