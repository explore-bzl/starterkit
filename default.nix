{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs_import_args = {
    inherit localSystem;
    config = {};
  };
  nixpkgs = import external_sources.nixpkgs nixpkgs_import_args;

  busyboxStatic = nixpkgs.callPackage ./nix/busyboxStatic.nix {};
  uninative = {
    "x86_64" = nixpkgs.callPackage ./nix/uninative.nix {uninative-arch = "x86_64";};
    "i686" = nixpkgs.callPackage ./nix/uninative.nix {uninative-arch = "i686";};
  };
  containerImages = nixpkgs.callPackage ./nix/containerImages.nix {
    inherit busyboxStatic uninative;
  };

  devShell = nixpkgs.callPackage ./nix/devShell.nix {};
in {
  inherit containerImages devShell nixpkgs uninative;
}
