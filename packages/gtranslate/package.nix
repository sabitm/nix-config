{
  lib,
  fetchurl,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "gtranslate";
  version = "1.1.2";
  meta = with lib; {
    description = "Google translate in command line";
    homepage = "https://github.com/sabitm/gtranslate";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ "sabitm" ];
  };

  src = fetchurl {
    url = "https://github.com/sabitm/gtranslate/releases/download/v1.1.2/gtranslate-x86_64-unknown-linux-gnu";
    hash = "sha256-hZJ1ILONHNcFHZNaY3hHdMHtrqRcN4BnsdYI3AJ3Xnw=";
  };

  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/gtranslate
    chmod +x $out/bin/gtranslate
  '';
}
