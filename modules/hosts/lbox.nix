{ config, ... }:

{
  # base: lbox hardware, no secrets, minimal home.
  flake.nixosConfigurations.base = config.flake.lib.mkHost {
    hostname = "base";
    hostModule = ../../hosts/lbox;
    withSops = false;
    extraModules = [ config.flake.modules.nixos.remote-builder ];
  };

  # lbox: full config with secrets.
  flake.nixosConfigurations.lbox = config.flake.lib.mkHost {
    hostname = "lbox";
    hostModule = ../../hosts/lbox;
    extraModules = [ config.flake.modules.nixos.remote-builder ];
  };
}
