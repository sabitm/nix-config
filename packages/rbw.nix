{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  pinentry-tty,
}:

stdenv.mkDerivation rec {
  pname = "rbw";
  version = "1.15.0";
  meta = with lib; {
    description = "Unofficial Bitwarden CLI";
    homepage = "https://github.com/doy/rbw";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ "sabitm" ];
  };

  src = fetchurl {
    url = "https://github.com/doy/rbw/releases/download/${version}/rbw_${version}_linux_amd64.tar.gz";
    hash = "sha256-2BdLCurMvNgDIspB+0i/LbrY/E1dnFCcQru0bV4ZU5U=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ pinentry-tty ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 rbw $out/bin/rbw
    install -Dm755 rbw-agent $out/bin/rbw-agent
    install -Dm644 completion/bash $out/share/bash-completion/completions/rbw
    install -Dm644 completion/fish $out/share/fish/vendor_completions.d/rbw.fish
    install -Dm644 completion/zsh $out/share/zsh/site-functions/_rbw
    wrapProgram $out/bin/rbw --prefix PATH : ${lib.makeBinPath [ pinentry-tty ]}
    runHook postInstall
  '';
}
