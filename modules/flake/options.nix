{ lib, ... }:

{
  # deferredModule merging so feature files spread across the tree can each
  # contribute to the same aggregate (e.g. flake.modules.nixos.base). Stock
  # flake-parts treats flake.* as freeform "raw" and would conflict instead.
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = "Reusable NixOS and home-manager modules aggregated across the module tree.";
  };
}
