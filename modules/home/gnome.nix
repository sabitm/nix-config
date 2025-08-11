{ config, pkgs, ... }:
let
  # GNOME extensions
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    removable-drive-menu
  ];
in
{
  # Add gnome extensions pkgs
  home.packages = extensions;

  # GNOME settings
  dconf.settings = {
    # Change GNOME theme to dark
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    # Disable App Search
    "org/gnome/desktop/search-providers" = {
      disable-external = true;
    };
    # Extensions
    "org/gnome/shell".enabled-extensions = map (ext: ext.extensionUuid) extensions;
    # Keybinds
    "org/gnome/desktop/wm/keybindings" = {
      # Disable alt-space
      activate-window-menu = [];
    };
  };

  # Set GTK theme
  gtk.enable = true;
  gtk.gtk3 = {
    enable = true;
    extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
