{ config, pkgs, ... }:
let
  # Add postman9 package
  postman9 = pkgs.callPackage ../packages/postman9.nix {};

  # GNOME extensions
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    removable-drive-menu
  ];
in
{
  imports = [
    ./subs/fish.nix
    ./subs/ghostty.nix
    ./subs/yazi.nix
    ./subs/zk.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sabit";
  home.homeDirectory = "/home/sabit";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    dbeaver-bin
    gimp
    jq
    postman9
  ] ++ extensions;

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable bat
  programs.bat.enable = true;

  # Enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable fzf
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable chrome
  programs.google-chrome.enable = true;

  # Enable zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable psd
  services.psd = {
    enable = true;
    browsers = [ "google-chrome" ];
  };
}
