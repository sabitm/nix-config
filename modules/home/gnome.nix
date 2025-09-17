{ config, pkgs, lib, ... }:
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
    "org/gnome/shell" = {
      # Extensions
      enabled-extensions = map (ext: ext.extensionUuid) extensions;
      # Make alt-tab switch on current workspace only
      "app-switcher/current-workspace-only" = true;
    };
    # Keybinds
    "org/gnome/desktop/wm/keybindings" = {
      # Disable alt-space
      activate-window-menu = [];
      # Windows related
      maximize = ["<Control><Super>k"];
      # Navigation
      move-to-workspace-right = ["<Shift><Super>k"];
      move-to-workspace-left = ["<Shift><Super>j"];
      switch-to-workspace-left = ["<Super>j"];
      switch-to-workspace-right = ["<Super>k"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # Disable meta-l keybinding for locking the screen
      screensaver = [];
      # Media keys
      volume-down = ["<Super>F11"];
      volume-up = ["<Super>F12"];
      volume-mute = ["<Super>F10"];
    };
    # Night light
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = (lib.hm.gvariant.mkUint32 4700);
    };
    # Desktop background
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    # Preferences
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
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
  gtk.gtk4 = {
    enable = true;
    extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
