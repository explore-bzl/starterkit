{
  containerImages,
  dockerTools,
  gnutar,
  lib,
  mkHelloWorldGlibc,
  skopeo,
  stdenv,
  writeShellScript,
  zstd,
}: let
  helloWorldGlibc = {
    "i686" = mkHelloWorldGlibc {is32Bit = true;};
    "x86_64" = mkHelloWorldGlibc {is32Bit = false;};
  };

  ubuntuDateutils = {
    "i686" = null;
    "x86_64" = import ../pkgs/ubuntuDateutils.nix {
      inherit gnutar stdenv zstd;
    };
  };

  buildPushContainerScript = import ./push.nix {
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
        name = "starterkit-${arch}-helloWorldGlibc";
        testImage = (builtins.getAttr "ash-${arch}" containerImages).image;
        testBinary = builtins.getAttr arch helloWorldGlibc;
        cmd = ["/bin/hello_cpp"];
      }
  )
  // {
    "x86_64-ubuntu" = buildStarterKitTest {
      name = "starterkit-x86_64-testUbuntuDateutils";
      testImage = (builtins.getAttr "ash-x86_64" containerImages).image;
      testBinary = builtins.getAttr "x86_64" ubuntuDateutils;
      cmd = ["/bin/dateutils.dseq" "2024-04-01" "2024-04-25" "--skip" "sat,sun"];
    };
  }
