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

  # Enable v4l2loopback kernel module
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];

  # Add v4l2loopback devices
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="DroidCam" exclusive_caps=1
  '';

  # Open ports for Wi-Fi connection
  networking.firewall.allowedTCPPorts = [ 4747 ];
  networking.firewall.allowedUDPPorts = [ 4747 ];

  # Networking
  networking.hostName = "${myconf.hostname}";
  networking.hostId = "8425e349";
}
