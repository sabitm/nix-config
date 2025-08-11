{ config, lib, pkgs, ... }:

{
  # Enable GNOME
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Exclude GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
  ];
}
