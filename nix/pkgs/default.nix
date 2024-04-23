{callPackage}: {
  busyboxStatic = callPackage ./busyboxStatic.nix {};
  uninative = callPackage ./uninative.nix {};
  helloWorldGlibc = callPackage ./helloWorldGlibc.nix {};
  ubuntuDateutils = callPackage ./ubuntuDateutils.nix {};
}
