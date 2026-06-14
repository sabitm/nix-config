{ config, ... }:

{
  # vbox: VM, no ZFS, no remote-builder.
  flake.nixosConfigurations.vbox = config.flake.lib.mkHost {
    hostname = "vbox";
    hostModule = ../../hosts/vbox;
  };
}
