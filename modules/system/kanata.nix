{ config, lib, pkgs, ... }:

{
  # Enable kanata
  services.kanata = {
    enable = true;
    keyboards.default.configFile = ../../data/kanata/default.kbd;
  };
}
