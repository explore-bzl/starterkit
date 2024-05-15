{
  containerImages,
  dockerTools,
  helloWorldGlibc,
  buildPushContainerScript,
  mkBwrapEnv,
  ubuntuDateutils,
  justbuild,
  buildPackages,
}: let
  buildStarterKitTest = {
    name,
    testImage,
    testBinary,
    cmd,
    ...
  }: rec {
    image = dockerTools.buildImage {
      inherit name;
      fromImage = testImage;
      copyToRoot = testBinary;
      config = {Cmd = cmd;};
    };
    push = buildPushContainerScript image;
    bwrap = mkBwrapEnv image;
  };

  ubuntuVariant = {
    "ash-x86_64-cc-ubuntu" = buildStarterKitTest {
      name = "starterkit-x86_64-cc-testUbuntuDateutils";
      testImage = containerImages."ash-x86_64-cc".image;
      testBinary = ubuntuDateutils;
      cmd = ["/bin/dateutils.dseq" "2024-04-01" "2024-04-25" "--skip" "sat,sun"];
    };
  };
in
  buildPackages {
    metaFun = variant: {
      name = "ash-${variant.arch}-hello";
      testImage = containerImages."ash-${variant.arch}".image;
      testBinary = helloWorldGlibc."${(builtins.replaceStrings ["-cc"] [""] variant.arch)}";
      cmd = ["/bin/hello_cpp"];
    };
    buildFun = buildStarterKitTest;
    variants = {
      attrs = {
        arch = ["i686-cc" "x86_64-cc"];
      };
    };
  }
  // buildPackages {
    metaFun = variant: {
      name = "ash-${variant.arch}-just";
      testImage = containerImages."ash-${variant.arch}".image;
      testBinary = justbuild;
      cmd = ["/bin/just" "--help"];
    };
    buildFun = buildStarterKitTest;
    variants = {
      attrs = {
        arch = ["i686-cc" "x86_64-cc"];
      };
    };
  }
  // ubuntuVariant
