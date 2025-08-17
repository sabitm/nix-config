{
  description = "A flake for Kiro AI editor";

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
          kiro = pkgs.callPackage ./package.nix {
            vscode-generic = (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix");
          };
        }
      );
    };
}
