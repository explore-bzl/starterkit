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
  path,
  lib,
}: let
  inherit (lib) cartesianProductOfSets nameValuePair listToAttrs;

  variants = cartesianProductOfSets {
    arch = ["x86_64" "i686"];
  };

  createOverriddenStdenv = {
    path,
    binutils-unwrapped,
    crossSystem ? null,
  }: let
    nixpkgs = import path {
      inherit crossSystem system;
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

  makeHelloWorldGlibcBinary = {
    name,
    arch,
  }: let
    overriddenStdenv = createOverriddenStdenv {
      inherit path;
      crossSystem =
        if arch == "i686"
        then {config = "i686-linux";}
        else null;
      binutils-unwrapped =
        if arch == "i686"
        then pkgsi686Linux.binutils-unwrapped
        else binutils-unwrapped;
    };
    interpreter =
      if arch == "i686"
      then "/lib/ld-linux.so.2"
      else "/lib64/ld-linux-x86-64.so.2";
  in
    overriddenStdenv.mkDerivation {
      name = "hello-world-dynamic-nostore-${name}";
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
        find "$out" -type f -exec remove-references-to -t ${overriddenStdenv.cc.libc} -t ${overriddenStdenv.cc.cc.lib} -t $out '{}' +
      '';
    };

  genMetadata = variant: {
    name = variant.arch;
  };
in
  listToAttrs (map (variant: let
    inherit (genMetadata variant) name;
  in
    nameValuePair name (makeHelloWorldGlibcBinary {
      inherit name;
      inherit (variant) arch;
    }))
  variants)
