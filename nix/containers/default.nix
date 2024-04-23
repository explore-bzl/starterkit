{callPackage}: let
  buildPushContainerScript = callPackage ./push.nix {};
  containerImages = callPackage ./images.nix {
    inherit buildPushContainerScript;
  };
  testContainerImages = callPackage ./tests.nix {
    inherit buildPushContainerScript containerImages;
  };
  pushAllContainerImages = callPackage ./pushAll.nix {
    inherit containerImages;
  };
in {
  inherit containerImages testContainerImages pushAllContainerImages;
}
