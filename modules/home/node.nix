{ config, lib, pkgs, home, ... }:

{
  # Add npm global folder
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  # Add to path
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];
}
