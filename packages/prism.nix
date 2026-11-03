{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  libayatana-appindicator,
  ffmpeg,
  glib,
  dbus,
}:

stdenv.mkDerivation rec {
  pname = "prism";
  version = "1.2.4";

  src = fetchurl {
    url = "https://github.com/FortoGraphy/prism-download-manager/releases/download/v${version}/Prism_${version}_amd64.deb";
    hash = "sha256-b4gJhQtknW9cFfsLkbrwZnWMyOjQoARPy0L1b5+gRA8=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
    libsoup_3
    openssl
    libayatana-appindicator
    glib
    dbus
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    webkitgtk_4_1
    libayatana-appindicator
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share
    mkdir -p $out/lib

    cp usr/bin/prism $out/bin/prism
    cp usr/bin/prism-native-host $out/bin/prism-native-host
    chmod +x $out/bin/prism $out/bin/prism-native-host

    cp -r usr/share/* $out/share/
    cp -r usr/lib/Prism $out/lib/Prism

    substituteInPlace $out/share/applications/Prism.desktop \
      --replace 'Exec=prism' "Exec=$out/bin/prism"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}
    )
  '';

  meta = with lib; {
    description = "Fast multi-connection download manager with browser integration";
    homepage = "https://github.com/FortoGraphy/prism-download-manager";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "prism";
    maintainers = with maintainers; [ ];
  };
}
