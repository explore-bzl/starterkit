{callPackage}: {
  bashStatic = callPackage ./bash {};
  busyboxStatic = callPackage ./busybox {};
  straceStatic = callPackage ./strace {};
  uninative = callPackage ./uninative {};
  helloWorldGlibc = callPackage ./hello {};
  ubuntuDateutils = callPackage ./dateutils {};
  justbuild = callPackage ./justbuild {};
}
