{ inputs, ... }:

{
  systems = [ "x86_64-linux" ];

  perSystem = { system, ... }: {
    # allowUnfree is required for the unfree custom packages (crossover, kiro, ...).
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
