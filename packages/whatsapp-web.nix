{
  lib,
  pkgs,
  stdenv,
  makeWrapper,
  writeText
}:
let
  browser = pkgs.google-chrome;
in
stdenv.mkDerivation rec {
  pname = "whatsapp-web-app";
  version = "1.0.0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  # Create the .desktop file content
  desktopItem = writeText "whatsapp-web.desktop" ''
    [Desktop Entry]
    Version=1.0
    Name=WhatsApp Web
    Comment=WhatsApp Web as a standalone application
    Exec=whatsapp-web-app
    # This relies on your icon theme (e.g., Papirus)
    # having an icon named 'whatsapp'.
    Icon=whatsapp
    Terminal=false
    Type=Application
    Categories=Network;InstantMessaging;
  '';

  installPhase = ''
    runHook preInstall

    # Create directories for our binary and desktop file
    mkdir -p $out/bin
    mkdir -p $out/share/applications

    # Create the wrapper script.
    makeWrapper ${browser}/bin/google-chrome-stable \
      $out/bin/whatsapp-web-app \
      --add-flags "--app=https://web.whatsapp.com" \
      --add-flags "--user-data-dir=\$HOME/.config/whatsapp-web-profile"

    # Install the .desktop file
    cp ${desktopItem} $out/share/applications/whatsapp-web.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wrapper to run WhatsApp Web as a standalone browser app";
    longDescription = ''
      Launches WhatsApp Web (web.whatsapp.com) in its own "app" window
      using the provided browser (e.g., Chromium or Google Chrome).
      It uses a dedicated profile directory
      ($HOME/.config/whatsapp-web-profile)
      to keep its session and data separate from your main browser.
    '';
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
