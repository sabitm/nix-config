{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  wrapGAppsHook3,
  atk,
  at-spi2-atk,
  at-spi2-core,
  alsa-lib,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  freetype,
  fontconfig,
  nss,
  nspr,
  pango,
  udev,
  libsecret,
  libuuid,
  libX11,
  libxcb,
  libXi,
  libXcursor,
  libXdamage,
  libXrandr,
  libXcomposite,
  libXext,
  libXfixes,
  libXrender,
  libXtst,
  libXScrnSaver,
  libxkbcommon,
  libdrm,
  libgbm,
  libglvnd,
  # Postman 9 requires the use of old Openssl 1.1
  openssl_1_1,
  xorg,
  copyDesktopItems,
  makeWrapper,
}:

let
  dist =
    {
      aarch64-linux = {
        arch = "arm64";
        sha256 = "sha256-XOQam1W7YT0YDesDR51G/cH318DcxpnAEiJg2JZU3Q4=";
      };

      x86_64-linux = {
        arch = "64";
        sha256 = "sha256-ZCfPE+bvPEQjEvUO/FQ1iNR9TG6GtI4vmj6yJ7B62iw=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation rec {
  pname = "postman";
  version = "9.31.0";
  meta = with lib; {
    homepage = "https://www.getpostman.com";
    changelog = "https://www.postman.com/release-notes/postman-app/#${
      replaceStrings [ "." ] [ "-" ] version
    }";
    description = "API Development Environment";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.postman;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers = with maintainers; [
      sabitm
    ];
  };

  src = fetchurl {
    url = "https://dl.pstmn.io/download/version/${version}/linux${dist.arch}";
    inherit (dist) sha256;
    name = "${pname}-${version}.tar.gz";
  };

  dontConfigure = true;

  desktopItems = [
    (makeDesktopItem {
      name = "postman";
      exec = "postman %U";
      icon = "postman";
      comment = "API Development Environment";
      desktopName = "Postman";
      genericName = "Postman";
      categories = [ "Development" ];
    })
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    atk
    at-spi2-atk
    at-spi2-core
    alsa-lib
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    freetype
    fontconfig
    libgbm
    nss
    nspr
    pango
    udev
    libdrm
    libglvnd
    libsecret
    libuuid
    libX11
    libxcb
    libXi
    libXcursor
    libXdamage
    libXrandr
    libXcomposite
    libXext
    libXfixes
    libXrender
    libXtst
    libXScrnSaver
    libxkbcommon
    xorg.libxshmfence
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/postman
    cp -R app/* $out/share/postman
    rm $out/share/postman/Postman

    mkdir -p $out/bin
    ln -s $out/share/postman/postman $out/bin/postman

    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime=true}}"

    mkdir -p $out/share/icons/hicolor/128x128/apps
    ln -s $out/share/postman/resources/app/assets/icon.png $out/share/icons/postman.png
    ln -s $out/share/postman/resources/app/assets/icon.png $out/share/icons/hicolor/128x128/apps/postman.png
    runHook postInstall
  '';

  postFixup = ''
    pushd $out/share/postman
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" postman
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" chrome_crashpad_handler
    for file in $(find . -type f \( -name \*.node -o -name postman -o -name \*.so\* \) ); do
      ORIGIN=$(patchelf --print-rpath $file); \
      patchelf --set-rpath "${lib.makeLibraryPath buildInputs}:$ORIGIN" $file
    done
    popd
    wrapProgram $out/bin/postman --set PATH ${lib.makeBinPath [ openssl_1_1 ]}
  '';
}
