{
  callPackage,
  containerImages,
}: {
  readme = callPackage ./readme.nix {inherit containerImages;};
}
