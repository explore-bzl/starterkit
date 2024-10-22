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
  bzl =
    (mkCallPackage (skitLib // {inherit images;}))
    ./bzl {};
  docs =
    (mkCallPackage (skitLib // {inherit images;}))
    ./docs {};
  devShell =
    (mkCallPackage {})
    ./devShell.nix {};
}
