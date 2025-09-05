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

    # Supported systems
    systems = [ "x86_64-linux" ];
    allSystems = nixpkgs.lib.genAttrs systems;
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

    packages = allSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        elyprismlauncher = pkgs.callPackage ./packages/elyprismlauncher.nix {};
        freedownloadmanager = pkgs.callPackage ./packages/freedownloadmanager.nix {};
        gtranslate = pkgs.callPackage ./packages/gtranslate.nix {};
        kiro = pkgs.callPackage ./packages/kiro.nix {
          vscode-generic = (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix");
        };
        postman9 = pkgs.callPackage ./packages/postman9.nix {};
      }
    );
  };
}
