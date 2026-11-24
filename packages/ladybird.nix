{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  ffmpeg,
  glib,
  libdrm,
  libglvnd,
  libpulseaudio,
  libxcb,
  libxcb-wm,
  liberation_ttf,
  qt6Packages,
  vulkan-loader,
  wayland,
}:

let
  sources = {
    x86_64-linux = {
      debArch = "amd64";
      hash = "sha256-t8T4zl7SrkMN+1CmqMubBu86KQOY3irRGTlmkBZ6muI=";
    };
    aarch64-linux = {
      debArch = "arm64";
      hash = "sha256-Bmx1s0PvR92w7hELIAxOXLGsCIGCSUtVNI6HKsPoTR8=";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system for ladybird");
  debRelease = "1~ubuntu26.04";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ladybird";
  version = "2026.47.7";

  src = fetchurl {
    # A tilde is not valid in the Nix store name.
    name = "ladybird_${finalAttrs.version}_${source.debArch}.deb";
    url = "https://apt.ladybird.org/pool/main/l/ladybird/ladybird_${finalAttrs.version}-${debRelease}_${source.debArch}.deb";
    inherit (source) hash;
  };

  licenseFile = fetchurl {
    name = "ladybird-${finalAttrs.version}-LICENSE";
    url = "https://raw.githubusercontent.com/LadybirdBrowser/ladybird/${finalAttrs.version}/LICENSE";
    hash = "sha256-J18YlErHukGsq7tGg4fByeji+B99SeZELa/jfCX/7qc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    glib
    libdrm
    libglvnd
    libpulseaudio
    libxcb
    libxcb-wm
    qt6Packages.qtbase
    qt6Packages.qtpositioning
    qt6Packages.qtwayland
    vulkan-loader
    wayland
  ];

  # Upstream lists these optional PowerVR and Steam libraries in its ELF metadata.
  autoPatchelfIgnoreMissingDeps = [
    "libGLES_CM.so.1"
    "libsteam_api.so"
  ];

  # Media helpers load extra codecs with dlopen and discard LD_LIBRARY_PATH.
  runtimeDependencies = [ (lib.getLib ffmpeg) ];

  strictDeps = true;
  sourceRoot = "root";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    # Keep the upstream paths relative to the browser and its helper processes.
    mkdir -p "$out"
    cp -r opt/ladybird/{bin,lib,libexec,share} "$out/"
    cp -r usr/share/. "$out/share/"
    ln -s Ladybird "$out/bin/ladybird"

    # Disable APT-based updates in the Nix package.
    rm "$out/share/Lagom/package-format"
    install -Dm644 "$licenseFile" "$out/share/licenses/ladybird/LICENSE"

    substituteInPlace \
      "$out/share/applications/org.ladybird.Ladybird.desktop" \
      "$out/share/dbus-1/services/org.ladybird.Ladybird.service" \
      --replace-fail /opt/ladybird/bin/Ladybird "$out/bin/ladybird"

    runHook postInstall
  '';

  preFixup = ''
    wrapQtApp "$out/bin/Ladybird" --suffix XDG_DATA_DIRS : ${liberation_ttf}/share
  '';

  meta = {
    description = "Truly independent web browser (alpha release)";
    homepage = "https://ladybird.org";
    license = lib.licenses.bsd2;
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ladybird";
  };
})
