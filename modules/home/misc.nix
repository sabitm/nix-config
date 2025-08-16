{ config, lib, pkgs, ... }:

{
  # Add binary
  home.packages = [
    (
      pkgs.writeScriptBin "replace" (
        builtins.readFile ../../data/misc/bin/replace
      )
    )
  ];

  # Scripts file
  home.file."Downloads/scripts/misc" = {
    source = ../../data/misc/scripts;
  };
}
