{ config, pkgs, ... }:

{
  # Enable fish
  programs.fish = {
    enable = true;
    plugins = [
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
    ];
    interactiveShellInit = ''
    # source all user-defined configs
    set -l userconfd "$HOME/.config/fish/userconf.d"
    if test -d $userconfd
        for file in $userconfd/*
            source $file
        end
    end
    '';
  };

  # Config file
  xdg.configFile."fish/userconf.d" = {
    source = ../../data/fish/userconf.d;
  };
}
