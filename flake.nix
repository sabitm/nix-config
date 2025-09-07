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

    # Host configuration
    optional = nixpkgs.lib.optional;
    hostConfig = { hostModule, homeModule, withSops ? true, ... }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          hostModule
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${myconf.username}" = homeModule;
            home-manager.sharedModules = [
              moduleArgs
            ] ++ optional withSops sops-nix.homeManagerModules.sops;
          }
          moduleArgs
        ] ++ optional withSops sops-nix.nixosModules.sops;
      };
  in
  {
    nixosConfigurations = {
      min = hostConfig {
        hostModule = ./hosts/min;
        homeModule = ./modules/home-min.nix;
        withSops = false;
      };

      lbox = hostConfig {
        hostModule = ./hosts/lbox;
        homeModule = ./modules/home.nix;
      };

      vbox = hostConfig {
        hostModule = ./hosts/vbox;
        homeModule = ./modules/home.nix;
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
