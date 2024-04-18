{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = {};
  };

  devShell = nixpkgs.callPackage ./nix/devShell.nix {};

  busyboxStatic = nixpkgs.callPackage ./nix/pkgs/busyboxStatic.nix {};

  uninative = nixpkgs.callPackage ./nix/pkgs/uninative.nix {};

  containerImages = nixpkgs.callPackage ./nix/containers/images.nix {inherit busyboxStatic uninative;};
  pushAllContainerImages = nixpkgs.callPackage ./nix/containers/pushAll.nix {inherit containerImages;};

  mkHelloWorldGlibc = {is32Bit ? false}:
    nixpkgs.callPackage ./nix/pkgs/helloWorldGlibc.nix {
      is32Bit = is32Bit;
      nixpkgs_src = external_sources.nixpkgs;
    };

  testContainerImages = nixpkgs.callPackage ./nix/containers/tests.nix {
    inherit containerImages mkHelloWorldGlibc;
  };
in {
  inherit containerImages devShell nixpkgs pushAllContainerImages uninative testContainerImages;
}
