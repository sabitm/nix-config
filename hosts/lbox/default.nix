{ config, pkgs, myconf, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
    ];

  # Enable ZFS support
  boot.supportedFilesystems.zfs = true;
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank0" ];

  # Mount ZFS volume filesystem
  fileSystems."/var/lib/docker" = {
    device = "/dev/zvol/tank0/arch/DATA/default/docker";
    fsType = "ext4";
  };

  # Preparing ZFS mountpoint
  system.activationScripts.setupMountDir = {
    deps = [ "users" ];
    text = ''
      mkdir -p /home/${myconf.username}/Downloads
      chown ${myconf.username}:users /home/${myconf.username}/Downloads
      mkdir -p /home/${myconf.username}/.cache
      chown ${myconf.username}:users /home/${myconf.username}/.cache
    '';
  };

  # Networking
  networking.hostName = "${myconf.hostname}";
  networking.hostId = "8425e349";
}
