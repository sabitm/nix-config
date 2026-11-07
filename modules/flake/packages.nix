{ inputs, ... }:

{
  perSystem = { pkgs, system, ... }: {
    packages = {
      crossover = pkgs.callPackage ../../packages/crossover.nix { };
      droidcam = pkgs.callPackage ../../packages/droidcam.nix { };
      elyprismlauncher = pkgs.callPackage ../../packages/elyprismlauncher.nix { };
      gtranslate = pkgs.callPackage ../../packages/gtranslate.nix { };
      nix-index-database = inputs.nix-index-database.packages.${system}.default;
      prism = pkgs.callPackage ../../packages/prism.nix { };
      rbw = pkgs.callPackage ../../packages/rbw.nix { };
      spread = pkgs.callPackage ../../packages/spread.nix { };
      steam-run = pkgs.callPackage ../../packages/steam-run.nix { };
      whatsapp-web = pkgs.callPackage ../../packages/whatsapp-web.nix { };
    };
  };
}
