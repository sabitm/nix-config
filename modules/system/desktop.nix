{ config, ... }:

{
  # Graphical layer: opted into by graphical hosts, omitted by minimal/server
  # hosts. Carries system-level desktop bits and wires the desktop home apps
  # into the user's home-manager config (mirrors base/secrets wiring).
  flake.modules.nixos.desktop = { myconf, pkgs, ... }: {
    # Nerd font for graphical terminals
    fonts.packages = with pkgs; [
      meslo-lgs-nf
    ];

    # Wayland clipboard utility
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];

    home-manager.users."${myconf.username}" = {
      imports = [ config.flake.modules.homeManager.desktop ];
    };
  };
}
