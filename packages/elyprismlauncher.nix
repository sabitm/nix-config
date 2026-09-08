{
  addDriverRunpath,
  alsa-lib,
  autoPatchelfHook,
  cmark,
  fetchurl,
  libarchive,
  gamemode,
  glfw3-minecraft,
  jre17_minimal,
  kdePackages,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXrandr,
  libXxf86vm,
  libjack2,
  libpulseaudio,
  mesa-demos,
  openal,
  pciutils,
  pipewire,
  stdenv,
  qrencode,
  tomlplusplus,
  udev,
  zlib,
  vulkan-loader,
  xrandr,

  gamemodeSupport ? stdenv.hostPlatform.isLinux,
  jdks ? [
    jre17_minimal
  ],
}:

stdenv.mkDerivation rec {
  pname = "elyprismlauncher";
  version = "11.1.0";

  src = fetchurl {
    url = "https://github.com/ElyPrismLauncher/Launcher/releases/download/${version}/PineconeMC-ArchLinux-${version}.pkg.tar.zst";
    hash = "sha256-cHxEmrdd2Uw/pZslYCgQi9xGKCKmeP1USsXaQ5KCGuA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    cmark
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtnetworkauth
    libarchive
    qrencode
    tomlplusplus
    zlib
  ]
  ++ lib.optional (
    lib.versionAtLeast kdePackages.qtbase.version "6" && stdenv.hostPlatform.isLinux
  ) kdePackages.qtwayland;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bin/* $out/bin
    cp -r share $out

    runHook postInstall
  '';

  qtWrapperArgs =
    let
      runtimeLibs = [
        (lib.getLib stdenv.cc.cc)
        ## native versions
        glfw3-minecraft
        openal

        ## openal
        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        ## glfw
        libGL
        libX11
        libXcursor
        libXext
        libXrandr
        libXxf86vm

        udev # oshi

        vulkan-loader # VulkanMod's lwjgl
      ]
      ++ lib.optional gamemodeSupport gamemode.lib;

      runtimePrograms = [
        mesa-demos
        pciutils # need lspci
        xrandr # needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
      ];
    in
    [ "--prefix PRISMLAUNCHER_JAVA_PATHS : ${lib.makeSearchPath "bin/java" jdks}" ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "--set LD_LIBRARY_PATH ${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}"
      "--prefix PATH : ${lib.makeBinPath runtimePrograms}"
    ];

  meta = with lib; {
    description = "Fork of Prism Launcher with integrated support for Ely.by";
    homepage = "https://github.com/ElyPrismLauncher/Launcher";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [  ];
  };
}
