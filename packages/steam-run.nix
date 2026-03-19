{
  lib,
  pkgs,
  stdenv
}:
let
  steam = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [
      # Additional pkgs
      pkgs.nss
    ];
  };
in steam.run
