{localSystem ? builtins.currentSystem, ...} @ args: let
  external_sources = import ./nix/sources.nix;

  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = {};
  };
  skitPkgs = nixpkgs.callPackage ./nix/pkgs {};
  callPackage = let
    allPkgs = nixpkgs // skitPkgs;
  in
    nixpkgs.lib.callPackageWith (allPkgs
      // {
        callPackage = nixpkgs.lib.callPackageWith allPkgs;
      });

  devShell = callPackage ./nix/devShell.nix {};
  images = callPackage ./nix/containers {};
in
  {
    inherit devShell;
  }
  // skitPkgs
  // images
