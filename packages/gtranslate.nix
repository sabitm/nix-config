{
  lib,
  fetchurl,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "gtranslate";
  version = "1.1.3";
  meta = with lib; {
    description = "Google translate in command line";
    homepage = "https://github.com/sabitm/gtranslate";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ "sabitm" ];
  };

  src = fetchurl {
    url = "https://github.com/sabitm/gtranslate/releases/download/v${version}/gtranslate-x86_64-unknown-linux-musl";
    hash = "sha256-C0qE7/TuTYI8w/2ri1KU5rwnbD1c/oKLrweWn8rGVC8=";
  };

  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/gtranslate
    chmod +x $out/bin/gtranslate
  '';
}
