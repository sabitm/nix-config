{ config, inputs, ... }:
let
  # Canonical personal config (username, ...). hostname is added per host.
  myconf = import ../../config.nix;
in
{
  flake.lib = {
    inherit (myconf) username;

    # Assemble a nixosSystem from the shared aggregates plus host specifics.
    mkHost = { hostname, hostModule, desktop ? true, withSops ? true, extraModules ? [ ] }:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          myconf = myconf // { inherit hostname; };
        };
        modules = [
          hostModule
          config.flake.modules.nixos.base
        ]
        ++ inputs.nixpkgs.lib.optional desktop config.flake.modules.nixos.desktop
        ++ inputs.nixpkgs.lib.optional withSops config.flake.modules.nixos.secrets
        ++ extraModules;
      };
  };
}
