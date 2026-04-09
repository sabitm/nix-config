{ config, pkgs, ... }:

{
  # Add packages
  home.packages = with pkgs; [
    bat
    dua
    fd
    file
    gcc
    jq
    just
    lazygit
    mpv
    ripgrep
    yt-dlp-light
  ];

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

  # Enable zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
