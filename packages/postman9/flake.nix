{
  description = "A flake for Postman 9";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          postman9 = pkgs.callPackage ./package.nix {};
        }
      );
    };
}
