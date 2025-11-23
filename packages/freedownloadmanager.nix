{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook3,
  autoPatchelfHook,
  udev,
  libdrm,
  libpqxx,
  unixODBC,
  gst_all_1,
  alsa-lib,
  libpulseaudio,
  libsForQt5,
}:

stdenv.mkDerivation rec {
  pname = "freedownloadmanager";
  version = "6.24.0";

  src = fetchurl {
    url = "https://files2.freedownloadmanager.org/fdm6_qt5/freedownloadmanager.deb";
    hash = "sha256-75WM1zV8gSfmVs2qrvLi5cJkayKTf4cu/FvYfuGaMac=";
  };

  unpackPhase = "dpkg-deb -x $src .";

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    libsForQt5.qt5.wrapQtAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    libdrm
    libpqxx
    unixODBC
    stdenv.cc.cc
    alsa-lib
    libpulseaudio
    libsForQt5.qt5.qtwayland
  ] ++ (with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]);

  runtimeDependencies = [
    (lib.getLib udev)
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt/freedownloadmanager $out
    cp -r usr/share $out
    ln -s $out/freedownloadmanager/fdm $out/bin/${pname}

    substituteInPlace $out/share/applications/freedownloadmanager.desktop \
      --replace 'Exec=/opt/freedownloadmanager/fdm' 'Exec=${pname}' \
      --replace "Icon=/opt/freedownloadmanager/icon.png" "Icon=$out/freedownloadmanager/icon.png"
  '';

  meta = with lib; {
    description = "A smart and fast internet download manager";
    homepage = "https://www.freedownloadmanager.org";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [  ];
  };
}
