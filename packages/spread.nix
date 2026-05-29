{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
}:

stdenv.mkDerivation rec {
  pname = "spread";
  version = "0.0.2";

  src = fetchurl {
    url = "https://github.com/sabitm/spread/releases/download/v${version}/spread-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-6Jq6gIP27wo+8VwGhxu0tX5y/6A6BMOcMjJuRHOFrZM=";
  };

  unpackPhase = ''
    unzip $src
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = [
    libxcb
    libxkbcommon
    wayland
    vulkan-loader
    stdenv.cc.cc
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp spread $out/bin/
    wrapProgram $out/bin/spread \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland vulkan-loader ]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "spread";
    homepage = "https://github.com/sabitm/spread";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ sabitm ];
    mainProgram = "spread";
  };
}
