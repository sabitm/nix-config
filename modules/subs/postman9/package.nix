{
  callPackage,
  lib,
}:

let
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
      johnrichardrinehart
      evanjs
      tricktron
      Crafter
    ];
  };

in

callPackage ./linux.nix { inherit pname version meta; }
