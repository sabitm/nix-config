{ ... }:

{
  flake.modules.homeManager.desktop = { config, pkgs, lib, ... }:
    let
      # GNOME extensions
      extensions = with pkgs.gnomeExtensions; [
        appindicator
        removable-drive-menu
      ];
      toggleAutoSuspend = pkgs.writeShellScriptBin "toggle-auto-suspend" ''
        set -eu
        idle_delay="$(${pkgs.glib}/bin/gsettings get org.gnome.desktop.session idle-delay | awk '{print $2}')"
        if [ "$idle_delay" = "0" ]; then
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.session idle-delay 300
          ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
          ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
          ${pkgs.libnotify}/bin/notify-send "Auto suspend" "Enabled"
        else
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.session idle-delay 0
          ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
          ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
          ${pkgs.libnotify}/bin/notify-send "Auto suspend" "Disabled"
        fi
      '';
    in
    {
      # Add gnome extensions pkgs
      home.packages = extensions ++ [ toggleAutoSuspend ];

      # GNOME settings
      dconf.settings = {
        # Change GNOME theme to dark
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        # Disable external search providers
        "org/gnome/desktop/search-providers" = {
          disable-external = true;
        };
        "org/gnome/shell" = {
          # Extensions
          enabled-extensions = map (ext: ext.extensionUuid) extensions;
        };
        "org/gnome/shell/window-switcher" = {
          # Make alt-tab switch on current workspace only
          current-workspace-only = true;
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
          switch-windows = ["<Alt>Tab"];
          switch-windows-backward = ["<Shift><Alt>Tab"];
          switch-applications = [];
          switch-applications-backward = [];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          # Disable meta-l keybinding for locking the screen
          screensaver = [];
          # Media keys
          volume-down = ["<Super>F11"];
          volume-up = ["<Super>F12"];
          volume-mute = ["<Super>F10"];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Suspend";
          command = "systemctl suspend";
          binding = "<Super><Shift>x";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "Toggle auto suspend";
          command = "toggle-auto-suspend";
          binding = "<Super><Shift>z";
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
      gtk = {
        enable = true;
        colorScheme = "dark";
      };
    };
}
