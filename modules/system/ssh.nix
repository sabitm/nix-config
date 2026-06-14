{ ... }:

{
  # Opt-in SSH server (starts on boot). Distinct from remote-builder, whose
  # sshd is force-disabled at boot and triggered manually.
  flake.modules.nixos.ssh = { myconf, ... }: {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
