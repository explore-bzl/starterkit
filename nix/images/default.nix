{callPackage}: let
  buildPushContainerScript = callPackage ./lib/pushContainerImage.nix {};
  mkBwrapEnv = callPackage ./lib/mkBwrap.nix {};
  containerImages = callPackage ./images.nix {
    inherit buildPushContainerScript mkBwrapEnv;
  };
  pushAllContainerImages = callPackage ./lib/pushAllContainerImages.nix {
    inherit containerImages;
  };
  testContainerImages = callPackage ./tests/default.nix {
    inherit buildPushContainerScript mkBwrapEnv containerImages;
  };
  runAllTestContainerImages = callPackage ./tests/lib/runTests.nix {
    inherit testContainerImages;
  };
in
  containerImages
  // {
    all.push = pushAllContainerImages;
    test =
      testContainerImages
      // {
        all.run = runAllTestContainerImages;
      };
  }
