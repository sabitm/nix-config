{ config, lib, home, ... }:

{
  # Enable git
  programs.git.enable = true;

  # Config file
  home.file.".gitconfig" = {
    source = ../../data/git/.gitconfig;
  };
}
