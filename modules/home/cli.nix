{ config, pkgs, ... }:

{
  # Add packages
  home.packages = with pkgs; [
    dua
  ];

  # Enable bat
  programs.bat.enable = true;

  # Enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable fd
  programs.fd.enable = true;

  # Enable fzf
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable jq
  programs.jq.enable = true;

  # Enable lazygit
  programs.lazygit.enable = true;

  # Enable ripgrep
  programs.ripgrep.enable = true;

  # Enable zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
