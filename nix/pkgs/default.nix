{callPackage}: {
  busyboxStatic = callPackage ./busybox {};
  uninative = callPackage ./uninative {};
  helloWorldGlibc = callPackage ./hello {};
  ubuntuDateutils = callPackage ./dateutils {};
}
