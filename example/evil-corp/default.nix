{localSystem ? builtins.currentSystem, ...}: let
  nixpkgs = let
    sources = import ../../nix/sources.nix;
  in
    import sources.nixpkgs {
      inherit localSystem;
      config = {};
    };
in
  nixpkgs.stdenv.mkDerivation {
    pname = "mystery-bin";
    version = "1.0.0";

    src = builtins.path {
      path = ./.;
      name = "myster-bin-srcs";
    };

    buildInputs = with nixpkgs; [gcc openssl.dev];

    buildPhase = ''
      gcc -lstdc++ -lcrypto mystery-bin.cpp -o mystery-bin
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv mystery-bin $out/bin/
    '';
  }
