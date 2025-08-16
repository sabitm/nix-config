{ config, lib, pkgs, ... }:

{
  # Enable zk
  programs.zk.enable = true;

  # Config file
  xdg.configFile."zk/config.toml" = {
    source = ../../data/zk/config.toml;
  };
}
