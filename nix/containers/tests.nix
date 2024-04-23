{
  containerImages,
  dockerTools,
  lib,
  helloWorldGlibc,
  buildPushContainerScript,
  ubuntuDateutils,
}: let
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
      config = {Cmd = cmd;};
    };
    push = buildPushContainerScript image;
  };
in
  lib.genAttrs ["i686-cc" "x86_64-cc"] (arch:
    buildStarterKitTest {
      name = "starterkit-${arch}-helloWorldGlibc";
      testImage = containerImages."ash-${arch}".image;
      testBinary = let
        cleanArch = builtins.replaceStrings ["-cc"] [""] arch;
      in
        helloWorldGlibc.${cleanArch};
      cmd = ["/bin/hello_cpp"];
    })
  // {
    "x86_64-cc-ubuntu" = buildStarterKitTest {
      name = "starterkit-x86_64-cc-testUbuntuDateutils";
      testImage = containerImages."ash-x86_64-cc".image;
      testBinary = ubuntuDateutils;
      cmd = ["/bin/dateutils.dseq" "2024-04-01" "2024-04-25" "--skip" "sat,sun"];
    };
  }
