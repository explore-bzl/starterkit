{localSystem ? builtins.currentSystem, ...}: let
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
  docs = callPackage ./nix/docs {inherit (images) containerImages;};
  images = callPackage ./nix/containers {};
in
  {
    inherit devShell docs;
  }
  // skitPkgs
  // images
