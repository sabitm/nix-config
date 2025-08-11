{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, ... }:
  let
    # Personal config
    myconf = import ./config.nix;

    # Pass additional args
    moduleArgs = {
      _module.args = { inherit myconf; };
    };
  in
  {
    nixosConfigurations = {
      lbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/lbox
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${myconf.username}" = ./modules/home.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              moduleArgs
            ];
          }
          sops-nix.nixosModules.sops
          moduleArgs
        ];
      };
    };
  };
}
