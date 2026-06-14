{ config, inputs, ... }:

{
  # Opt-in secrets layer: sops on both NixOS and home-manager sides.
  flake.modules.nixos.secrets = { myconf, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    home-manager.users."${myconf.username}" = {
      imports = [ config.flake.modules.homeManager.secrets ];
    };
  };
}
