{ config, lib, pkgs, ... }:

{
  # Enable GNOME
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Exclude GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
  ];

  # Mime settings
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/bmp" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/heif" = "org.gnome.Loupe.desktop";
      "image/tiff" = "org.gnome.Loupe.desktop";
    };
  };
}
