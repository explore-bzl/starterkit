{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = {};
  };

  busyboxStatic = nixpkgs.callPackage ./nix/busyboxStatic.nix {};

  mkUninative = arch: nixpkgs.callPackage ./nix/uninative.nix {uninative-arch = arch;};

  uninative = nixpkgs.lib.genAttrs ["x86_64" "i686"] mkUninative;

  containerImages = nixpkgs.callPackage ./nix/containerImages.nix {inherit busyboxStatic uninative;};

  devShell = nixpkgs.callPackage ./nix/devShell.nix {};
in {
  inherit containerImages devShell nixpkgs uninative;
}
