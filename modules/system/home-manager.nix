{ config, inputs, ... }:

{
  # Wire home-manager into every NixOS host and feed it the base home aggregate.
  flake.modules.nixos.base = { myconf, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit myconf; };
    home-manager.users."${myconf.username}" = {
      imports = [ config.flake.modules.homeManager.base ];
    };
  };
}
