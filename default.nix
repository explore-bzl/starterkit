{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = {};
  };
  
  devShell = nixpkgs.callPackage ./nix/devShell.nix {};

  busyboxStatic = nixpkgs.callPackage ./nix/pkgs/busyboxStatic.nix {};

  mkUninative = arch: nixpkgs.callPackage ./nix/pkgs/uninative.nix {uninative-arch = arch;};

  uninative = nixpkgs.lib.genAttrs ["x86_64" "i686"] mkUninative;

  containerImages = nixpkgs.callPackage ./nix/containers/images.nix {inherit busyboxStatic uninative;};

  mkHelloWorldGlibc = {is32Bit ? false}:
    nixpkgs.callPackage ./nix/pkgs/helloWorldGlibc.nix {
      is32Bit = is32Bit;
      nixpkgs_src = external_sources.nixpkgs;
    };

  testContainerImages = nixpkgs.callPackage ./nix/containers/tests.nix {
    inherit containerImages mkHelloWorldGlibc;
  };
in {
  inherit containerImages devShell nixpkgs uninative testContainerImages;
}
