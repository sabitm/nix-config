{ config, myconf, pkgs, ... }:
let
  # Config dir
  homeDir = "/home/${myconf.username}";
  configHome = "${homeDir}/.config";
in
{
  # Add vim alias script
  home.packages = [
    (
      pkgs.writeScriptBin "vim" ''
      #!/bin/sh
      nvim -u ${configHome}/nvim/init-lite.lua "${"$"}{@}"
      ''
    )
  ];
}
