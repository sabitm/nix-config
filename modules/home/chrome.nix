{ config, lib, ... }:

{
  # Enable chrome
  programs.google-chrome.enable = true;

  # Enable psd
  services.psd = {
    enable = true;
    browsers = [ "google-chrome" ];
  };
}
