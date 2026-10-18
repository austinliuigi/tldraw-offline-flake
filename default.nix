# To update to new version:
#   - update ${version}
#   - update x86_64 hash to `nix store prefetch-file --json "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage" | jq -r .hash`
#   - update arm64 hash to `nix store prefetch-file --json "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-arm64.AppImage" | jq -r .hash`
{
  appimageTools,
  fetchurl,
  lib,
  stdenv,
}: let
  pname = "tldraw-offline";
  version = "1.22.0";

  sources = {
    x86_64-linux = {
      suffix = "x86_64";
      hash = "sha256-oNrKSPW7+8+4XCstSg562X51cQSXpe8bsS5t4bsuaXg=";
    };
    aarch64-linux = {
      suffix = "arm64";
      hash = "sha256-B69shL1yJCPxtMfndbguYWwTzDbFS6boUY4G3mQhFrE=";
    };
  };

  source = sources.${stdenv.hostPlatform.system}
    or (throw "${pname}: unsupported system ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-${source.suffix}.AppImage";
    hash = source.hash;
  };

  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/tldraw-offline.desktop \
        $out/share/applications/tldraw-offline.desktop
      install -Dm444 ${appimageContents}/tldraw-offline.png \
        $out/share/icons/hicolor/512x512/apps/tldraw-offline.png
      substituteInPlace $out/share/applications/tldraw-offline.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    '';

    meta = {
      description = "tldraw-offline";
      homepage = "https://github.com/tldraw/tldraw-offline";
      license = lib.licenses.unfree;
      mainProgram = "tldraw-offline";
      platforms = builtins.attrNames sources;
    };
  }
