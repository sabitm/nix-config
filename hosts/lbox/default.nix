{ config, lib, pkgs, ... }:

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
  fileSystems."/var/lib/docker" =
    { device = "/dev/zvol/tank0/arch/DATA/default/docker";
      fsType = "ext4";
    };

  # Preparing ZFS mountpoint
  system.activationScripts.setupMountDir = {
    deps = [ "users" ];
    text = ''
      mkdir -p /home/sabit/Downloads
      chown sabit:users /home/sabit/Downloads
      mkdir -p /home/sabit/.cache
      chown sabit:users /home/sabit/.cache
    '';
  };

  # Networking
  networking.hostName = "lbox";
  networking.hostId = "007f0200";
}
