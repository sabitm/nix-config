{ config, pkgs, myconf, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Networking
  networking.hostName = "${myconf.hostname}";
  networking.hostId = "8425e349";
}
