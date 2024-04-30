{localSystem ? builtins.currentSystem, ...}: let
  nixpkgs = let
    sources = import ./nix/sources.nix;
  in
    import sources.nixpkgs {
      inherit localSystem;
      config = {};
    };

  mkCallPackage = extraPkgs: let
    allPkgs = nixpkgs // extraPkgs;
  in
    nixpkgs.lib.callPackageWith (allPkgs
      // {
        callPackage = nixpkgs.lib.callPackageWith allPkgs;
      });

  skitLib =
    (mkCallPackage {})
    ./nix/lib {};

  skitPkgs =
    (mkCallPackage skitLib)
    ./nix/pkgs {};

  images =
    (mkCallPackage (skitLib // skitPkgs))
    ./nix/containers {};

  devShell =
    (mkCallPackage {})
    ./nix/devShell.nix {};

  docs =
    (mkCallPackage {inherit (images) containerImages;})
    ./nix/docs {};
in
  {
    inherit devShell docs;
  }
  // skitPkgs
  // images
