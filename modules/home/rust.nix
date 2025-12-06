{ config, pkgs, ... }:

{
  home.file.".cargo/config.toml" = {
    text = ''
      [build]
      rustc-wrapper = "sccache"

      [target.x86_64-unknown-linux-gnu]
      rustflags = ["-C", "link-arg=-fuse-ld=mold"]

      [target.aarch64-unknown-linux-gnu]
      rustflags = ["-C", "link-arg=-fuse-ld=mold"]
    '';
  };
}
