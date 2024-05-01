{basePkgs}: extraPkgs: let
  allPkgs = basePkgs // extraPkgs;
in
  basePkgs.lib.callPackageWith (allPkgs
    // {
      callPackage = basePkgs.lib.callPackageWith allPkgs;
    })
