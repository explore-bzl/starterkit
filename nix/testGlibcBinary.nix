{
  stdenv,
  patchelf,
  removeReferencesTo,
  writeTextDir,
  system,
  wrapCCWith,
  wrapBintoolsWith,
  binutils-unwrapped,
  overrideCC,
  pkgsi686Linux,
  nixpkgs_src,
  is32Bit ? false,
}: let
  createOverriddenStdenv = {
    nixpkgs_src,
    binutils-unwrapped,
    crossSystem ? null,
  }: let
    nixpkgs = import nixpkgs_src {
      inherit system;
      crossSystem = crossSystem;
    };
    wrappedGcc = wrapCCWith {
      cc = nixpkgs.gcc-unwrapped;
      bintools = wrapBintoolsWith {
        bintools = binutils-unwrapped;
        libc = nixpkgs.glibc;
      };
    };
  in
    overrideCC stdenv wrappedGcc;

  overriddenStdenv = createOverriddenStdenv {inherit binutils-unwrapped nixpkgs_src;};
  overriddenStdenv32 = createOverriddenStdenv {
    inherit nixpkgs_src;
    crossSystem = {config = "i686-linux";};
    binutils-unwrapped = pkgsi686Linux.binutils-unwrapped;
  };

  chosenStdenv =
    if is32Bit
    then overriddenStdenv32
    else overriddenStdenv;
  interpreter =
    if is32Bit
    then "/lib/ld-linux.so.2"
    else "/lib64/ld-linux-x86-64.so.2";

  createSource = name: code: writeTextDir name code;

  src = createSource "hello.c" ''
    #include <stdio.h>
    int main(void) {
      printf("Hello, World in C!\n");
      return 0;
    }
  '';

  srcCpp = createSource "hello.cpp" ''
    #include <iostream>
    int main() {
      std::cout << "Hello, World in C++!" << std::endl;
      return 0;
    }
  '';

  makeTestGlibcBinary = stdenv: interpreter:
    stdenv.mkDerivation {
      name = "hello-world-dynamic-nostore";
      nativeBuildInputs = [patchelf removeReferencesTo];
      phases = ["buildPhase" "installPhase"];
      buildPhase = ''
        gcc ${src}/hello.c -o hello_c
        g++ ${srcCpp}/hello.cpp -o hello_cpp
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp hello* $out/bin/
        find "$out" -type f -exec patchelf --set-interpreter ${interpreter} --remove-rpath '{}' +
        find "$out" -type f -exec remove-references-to -t ${stdenv.cc.libc} -t ${stdenv.cc.cc.lib} -t $out '{}' +
      '';
    };
in
  makeTestGlibcBinary chosenStdenv interpreter
