{ inputs, ... }:

{
  perSystem = { pkgs, system, ... }: {
    packages = {
      crossover = pkgs.callPackage ../../packages/crossover.nix { };
      elyprismlauncher = pkgs.callPackage ../../packages/elyprismlauncher.nix { };
      freedownloadmanager = pkgs.callPackage ../../packages/freedownloadmanager.nix { };
      gtranslate = pkgs.callPackage ../../packages/gtranslate.nix { };
      hurl = pkgs.callPackage ../../packages/hurl.nix { };
      kiro = pkgs.callPackage ../../packages/kiro.nix {
        vscode-generic = (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix");
      };
      nix-index-database = inputs.nix-index-database.packages.${system}.default;
      postman9 = pkgs.callPackage ../../packages/postman9.nix { };
      rbw = pkgs.callPackage ../../packages/rbw.nix { };
      spread = pkgs.callPackage ../../packages/spread.nix { };
      steam-run = pkgs.callPackage ../../packages/steam-run.nix { };
      whatsapp-web = pkgs.callPackage ../../packages/whatsapp-web.nix { };
    };
  };
}
