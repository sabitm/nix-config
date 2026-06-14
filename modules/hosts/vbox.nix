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
      config.flake.modules.nixos.ssh
      # base enables zram at normal priority; mkForce to opt this host out.
      ({ lib, ... }: { zramSwap.enable = lib.mkForce false; })
      # amdgpu caps GTT (GPU-usable system RAM) at half of RAM = 8 GiB by default.
      # This raise it to 13 GiB (3256738 * 4 KiB pages), leaving 3 GiB for the host.
      ({ ... }: {
        boot.kernelParams = [ "ttm.pages_limit=3256738" "ttm.page_pool_size=3256738" ];
      })
    ];
  };
}
