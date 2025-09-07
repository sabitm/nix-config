{ config, pkgs, myconf, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
    ];

  # Networking
  networking.hostName = "${myconf.hostname}";
  networking.hostId = "8425e349";
}
