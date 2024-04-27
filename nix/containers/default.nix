{callPackage}: let
  buildPushContainerScript = callPackage ./push.nix {};
  mkBwrapEnv = callPackage ./bwrap.nix {};
  containerImages = callPackage ./images.nix {
    inherit buildPushContainerScript mkBwrapEnv;
  };
  testContainerImages = callPackage ./tests.nix {
    inherit buildPushContainerScript mkBwrapEnv containerImages;
  };
  pushAllContainerImages = callPackage ./pushAll.nix {
    inherit containerImages;
  };
  runAllTestContainerImages = callPackage ./runTests.nix {
    inherit testContainerImages;
  };
in {
  inherit containerImages testContainerImages pushAllContainerImages runAllTestContainerImages;
}
