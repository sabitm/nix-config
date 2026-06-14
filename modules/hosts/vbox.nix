{ config, ... }:

{
  # vbox: VM, no ZFS, no remote-builder.
  flake.nixosConfigurations.vbox = config.flake.lib.mkHost {
    hostname = "vbox";
    hostModule = ../../hosts/vbox;
  };

  # vbox-min: minimal/server variant of vbox, no desktop. Shares vbox hardware.
  flake.nixosConfigurations.vbox-min = config.flake.lib.mkHost {
    hostname = "vbox-min";
    hostModule = ../../hosts/vbox;
    desktop = false;
    extraModules = [
      # base enables zram at normal priority; mkForce to opt this host out.
      ({ lib, ... }: { zramSwap.enable = lib.mkForce false; })
      config.flake.modules.nixos.ssh
    ];
  };
}
