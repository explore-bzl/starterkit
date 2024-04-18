{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = {};
  };

  mkTestGlibcBinary = {is32Bit ? false}:
    nixpkgs.callPackage ./nix/testGlibcBinary.nix {
      is32Bit = is32Bit;
      nixpkgs_src = external_sources.nixpkgs;
    };

  busyboxStatic = nixpkgs.callPackage ./nix/busyboxStatic.nix {};

  mkUninative = arch: nixpkgs.callPackage ./nix/uninative.nix {uninative-arch = arch;};

  uninative = nixpkgs.lib.genAttrs ["x86_64" "i686"] mkUninative;

  containerImages = nixpkgs.callPackage ./nix/containerImages.nix {inherit busyboxStatic uninative;};

  testContainerImages = nixpkgs.callPackage ./nix/tests.nix {
    inherit containerImages mkTestGlibcBinary;
  };

  devShell = nixpkgs.callPackage ./nix/devShell.nix {};
in {
  inherit containerImages devShell nixpkgs uninative testContainerImages;
}
