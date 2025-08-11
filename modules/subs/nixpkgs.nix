{ config, lib, ... }:

{
  # Nixpkgs config file
  xdg.configFile."nixpkgs/config.nix" = {
    source = ../../data/nixpkgs/config.nix;
  };
}
