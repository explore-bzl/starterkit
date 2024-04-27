{
  patchelf,
  removeReferencesTo,
  writeTextDir,
  lib,
  gccMultiStdenv,
}: let
  inherit (lib) cartesianProductOfSets nameValuePair listToAttrs optionalString;

  variants = cartesianProductOfSets {
    arch = ["x86_64" "i686"];
  };

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
    interpreter =
      if arch == "i686"
      then "/lib/ld-linux.so.2"
      else "/lib64/ld-linux-x86-64.so.2";
  in
    gccMultiStdenv.mkDerivation {
      name = "hello-world-dynamic-nostore-${name}";
      nativeBuildInputs = [patchelf removeReferencesTo];
      phases = ["buildPhase" "installPhase"];
      buildPhase = ''
        gcc ${src}/hello.c ${optionalString (arch == "i686") "-m32"} -o hello_c
        g++ ${srcCpp}/hello.cpp ${optionalString (arch == "i686") "-m32"} -o hello_cpp
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp hello* $out/bin/
        find "$out" -type f -exec patchelf --set-interpreter ${interpreter} --remove-rpath '{}' +
        find "$out" -type f -exec remove-references-to -t ${gccMultiStdenv.cc.libc} -t ${gccMultiStdenv.cc.cc.lib} -t $out '{}' +
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
