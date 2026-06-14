{ ... }:

{
  flake.modules.nixos.base = { ... }: {
    # Enable kanata
    services.kanata = {
      enable = true;
      keyboards.default.configFile = ../../data/kanata/default.kbd;
    };
  };
}
