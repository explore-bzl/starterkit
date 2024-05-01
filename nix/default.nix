{nixpkgs}: let
  mkCallPackage = import ./lib/mkCallPackage.nix {basePkgs = nixpkgs;};
  skitLib =
    (mkCallPackage {})
    ./lib {};
in rec {
  pkgs =
    (mkCallPackage skitLib)
    ./pkgs {};
  images =
    (mkCallPackage (skitLib // pkgs))
    ./images {};
  docs =
    (mkCallPackage {inherit images;})
    ./docs {};
  devShell =
    (mkCallPackage {})
    ./devShell.nix {};
}
