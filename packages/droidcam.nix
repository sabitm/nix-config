{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  gtk3,
  libappindicator-gtk3,
  speex,
  alsa-lib,
  libX11,
  pango,
  glib,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "droidcam-bin";
  version = "2.1.5";

  src = fetchurl {
    url = "https://github.com/dev47apps/droidcam-linux-client/releases/download/v${version}/droidcam_${version}.zip";
    hash = "sha256-qy5TdcS0lu5+ymXiIcNdUOPMJ/dbGVwqtWPoFdENurE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    speex
    alsa-lib
    libX11
    pango
    glib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  # Official binaries already embed libturbojpeg and libswscale.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 droidcam $out/bin/droidcam
    install -Dm755 droidcam-cli $out/bin/droidcam-cli
    install -Dm644 icon2.png $out/share/icons/hicolor/96x96/apps/droidcam.png
    install -Dm644 droidcam.desktop $out/share/applications/droidcam.desktop

    substituteInPlace $out/share/applications/droidcam.desktop \
      --replace-fail "/opt/droidcam-icon.png" "droidcam" \
      --replace-fail "/usr/local/bin/droidcam" "droidcam"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Official DroidCam Linux client binary (statically linked libturbojpeg)";
    homepage = "https://github.com/dev47apps/droidcam-linux-client";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "droidcam";
  };
}
