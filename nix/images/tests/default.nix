{
  containerImages,
  dockerTools,
  helloWorldGlibc,
  buildPushContainerScript,
  mkBwrapEnv,
  ubuntuDateutils,
  genVariants,
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

  genMetadata = variant: {
    name = "ash-${variant.arch}";
    testImage = containerImages."ash-${variant.arch}".image;
    testBinary = helloWorldGlibc."${(builtins.replaceStrings ["-cc"] [""] variant.arch)}";
    cmd = ["/bin/hello_cpp"];
  };

  variants = genVariants {
    attrs = {
      arch = ["i686-cc" "x86_64-cc"];
    };
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
    metaFun = genMetadata;
    buildFun = buildStarterKitTest;
    variants = variants;
  }
  // ubuntuVariant
