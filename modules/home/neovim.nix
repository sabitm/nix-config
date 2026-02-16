{ config, myconf, pkgs, ... }:
let
  # Config dir
  homeDir = "/home/${myconf.username}";
  configHome = "${homeDir}/.config";
in
{
  # Add nv script
  home.packages = [
    (
      pkgs.writeScriptBin "nv" ''
      #!/bin/sh
      nvim -u ${configHome}/nvim/init-lite.lua "${"$"}{@}"
      ''
    )
  ];
}
