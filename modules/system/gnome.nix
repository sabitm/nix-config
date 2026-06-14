{ ... }:

{
  flake.modules.nixos.desktop = { config, lib, pkgs, ... }: {
    # Enable GNOME
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;

    # Exclude GNOME packages
    environment.gnome.excludePackages = with pkgs; [
      gnome-console
      gnome-characters
      gnome-contacts
      gnome-connections
      gnome-disk-utility
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-music
      gnome-system-monitor
      gnome-tour
      gnome-user-docs
      gnome-weather
      baobab
      decibels
      epiphany
      seahorse
      showtime
      simple-scan
      snapshot
      yelp
    ];

    # Add geary email client
    programs.geary.enable = true;

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
  };
}
