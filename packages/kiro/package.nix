{
  lib,
  stdenv,
  callPackage,
  vscode-generic,
  fetchurl,
  undmg,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  inherit (stdenv) hostPlatform;

  sources = {
    x86_64-linux = fetchurl {
      url = "https://prod.download.desktop.kiro.dev/releases/202508160530--distro-linux-x64-tar-gz/202508160530-distro-linux-x64.tar.gz";
      hash = "sha256-HE5LuCJ7TZ1qJ/jN4rYhRTslKh+1O1ObhC3WGw5sOw8=";
    };
  };

  source = sources.${hostPlatform.system};
in
callPackage vscode-generic rec {
  inherit useVSCodeRipgrep commandLineArgs;

  version = "0.2.14";
  pname = "kiro";

  executableName = "kiro";
  longName = "Kiro";
  shortName = "kiro";
  libraryName = "kiro";
  iconName = "kiro";

  src = source;

  sourceRoot = if hostPlatform.isLinux then "Kiro" else "Kiro.app";

  tests = { };

  updateScript = "";

  # Editing the `kiro` binary within the app bundle causes the bundle's signature
  # to be invalidated, which prevents launching starting with macOS Ventura, because Kiro is notarized.
  # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
  dontFixup = stdenv.hostPlatform.isDarwin;

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://kiro.dev";
    changelog = "https://kiro.dev";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [
      sabitm
    ];
    platforms = [
      "x86_64-linux"
    ]
    ++ lib.platforms.darwin;
    mainProgram = "kiro";
  };
}
