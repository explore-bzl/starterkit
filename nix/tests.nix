{
  containerImages,
  dockerTools,
  gnutar,
  lib,
  mkTestGlibcBinary,
  skopeo,
  stdenv,
  writeShellScript,
  zstd,
}: let
  testGlibcBinary = {
    "i686" = mkTestGlibcBinary {is32Bit = true;};
    "x86_64" = mkTestGlibcBinary {is32Bit = false;};
  };

  ubuntuDateutils = {
    "i686" = null;
    "x86_64" = import ./ubuntuDateutils.nix {
      inherit gnutar stdenv zstd;
    };
  };

  buildPushContainerScript = import ./pushContainerImage.nix {
    inherit lib skopeo writeShellScript;
  };

  buildStarterKitTest = {
    name,
    testImage,
    testBinary,
    cmd,
  }: rec {
    image = dockerTools.buildImage {
      inherit name;
      fromImage = testImage;
      copyToRoot = testBinary;
      config = {
        Cmd = cmd;
      };
    };
    push = buildPushContainerScript image;
  };
in
  lib.genAttrs [
    "i686"
    "x86_64"
  ] (
    arch:
      buildStarterKitTest {
        name = "starterkit-${arch}-testGlibcBinary";
        testImage = (builtins.getAttr arch containerImages).image;
        testBinary = (builtins.getAttr arch testGlibcBinary);
        cmd = ["/bin/hello_cpp"];
      }
  )
  // {
    "x86_64-ubuntu" = buildStarterKitTest {
      name = "starterkit-x86_64-testUbuntuDateutils";
      testImage = (builtins.getAttr "ash-x86_64" containerImages).image;
      testBinary = (builtins.getAttr "x86_64" ubuntuDateutils);
      cmd = ["/bin/dateutils.dseq" "2024-04-01" "2024-04-25" "--skip" "sat,sun"];
    };
  }
