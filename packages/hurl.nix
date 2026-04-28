{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  curl,
  openssl,
  libxml2_13,
}:

stdenv.mkDerivation rec {
  pname = "hurl";
  version = "8.0.0";

  src = fetchurl {
    url = "https://github.com/Orange-OpenSource/hurl/releases/download/${version}/hurl-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-arHWcDuUCG7ObS+ZTXP40hWSaZeykropuJR5lCWvv2c=";
  };

  sourceRoot = "hurl-${version}-x86_64-unknown-linux-gnu";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    curl
    openssl
    libxml2_13
    stdenv.cc.cc
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/man/man1 \
      $out/share/bash-completion/completions \
      $out/share/fish/vendor_completions.d \
      $out/share/zsh/site-functions

    cp bin/hurl bin/hurlfmt $out/bin/
    cp man/man1/hurl.1.gz man/man1/hurlfmt.1.gz $out/share/man/man1/
    cp completions/hurl.bash $out/share/bash-completion/completions/hurl
    cp completions/hurlfmt.bash $out/share/bash-completion/completions/hurlfmt
    cp completions/hurl.fish $out/share/fish/vendor_completions.d/hurl.fish
    cp completions/hurlfmt.fish $out/share/fish/vendor_completions.d/hurlfmt.fish
    cp completions/_hurl $out/share/zsh/site-functions/_hurl
    cp completions/_hurlfmt $out/share/zsh/site-functions/_hurlfmt
    runHook postInstall
  '';

  meta = with lib; {
    description = "Runs and tests HTTP requests defined in a simple plain text format";
    homepage = "https://hurl.dev";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ sabitm ];
    mainProgram = "hurl";
  };
}
