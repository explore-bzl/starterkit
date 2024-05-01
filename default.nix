{localSystem ? builtins.currentSystem, ...}: let
  nixpkgs = let
    sources = import ./nix/sources.nix;
  in
    import sources.nixpkgs {
      inherit localSystem;
      config = {};
    };
in
  import ./nix {inherit nixpkgs;}
