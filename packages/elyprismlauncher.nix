{
  addDriverRunpath,
  alsa-lib,
  autoPatchelfHook,
  cmark,
  fetchurl,
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
  tomlplusplus,
  udev,
  vulkan-loader,
  xrandr,

  gamemodeSupport ? stdenv.hostPlatform.isLinux,
  jdks ? [
    jre17_minimal
  ],
}:

stdenv.mkDerivation rec {
  pname = "elyprismlauncher";
  version = "9.5";

  src = fetchurl {
    url = "https://github.com/ElyPrismLauncher/ElyPrismLauncher/releases/download/${version}/ElyPrismLauncher-ArchLinux-x86_64-${version}.pkg.tar.zst";
    hash = "sha256-QB1uOqHlPRF+Bxm+Pk0eTZgxvk8nJ2EzjGrbJ1MS3Bs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    cmark
    kdePackages.qt5compat
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtnetworkauth
    kdePackages.quazip
    tomlplusplus
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
    homepage = "https://github.com/ElyPrismLauncher/ElyPrismLauncher";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [  ];
  };
}
