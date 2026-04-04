{ lib, myconf, ... }:

{
  # SSH configuration with manual trigger
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  systemd.services.sshd.wantedBy = lib.mkForce [];

  nix.settings.trusted-users = [ myconf.username ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
