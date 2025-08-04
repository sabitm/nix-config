{ config, pkgs, ... }:
let
  # Add postman9 package
  postman9 = pkgs.callPackage ./subs/postman9/package.nix {};
in
{
  imports = [
    ./subs/yazi.nix
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
    postman9
    slack
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sabit/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "nvim";
  };

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

  # Enable chrome
  programs.google-chrome.enable = true;

  # Enable direnv
  programs.bash.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
