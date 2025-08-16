{ config, lib, pkgs, ... }:

{
  # Enable yazi
  programs.yazi = {
    enable = true;
    plugins = {
      smart-switch = ../../data/yazi/plugins/smart-switch.yazi;
    };
    flavors = {
      gruvbox-dark = ../../data/yazi/plugins/gruvbox-dark.yazi;
    };
  };

  # Config file
  xdg.configFile = {
    "yazi/yazi.toml" = {
      source = ../../data/yazi/yazi.toml;
    };
    "yazi/keymap.toml" = {
      source = ../../data/yazi/keymap.toml;
    };
    "yazi/theme.toml" = {
      source = ../../data/yazi/theme.toml;
    };
  };
}
