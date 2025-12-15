{ config, lib, pkgs, ... }:

{
  # Add binary
  home.packages = [
    (
      pkgs.writeScriptBin "replace" (
        builtins.readFile ../../data/misc/bin/replace
      )
    )
    (
      pkgs.writeScriptBin "getlines" (
        builtins.readFile ../../data/misc/bin/getlines
      )
    )
  ];

  # Scripts file
  home.file."Downloads/scripts/misc" = {
    source = ../../data/misc/scripts;
  };
}
