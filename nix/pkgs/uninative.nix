{
  stdenv,
  fetchurl,
  lib,
}: let
  inherit
    (lib)
    cartesianProductOfSets
    concatStringsSep
    filter
    nameValuePair
    listToAttrs
    optionalString
    ;

  name = "yocto-uninative";
  version = "4.4";
  baseURL = "http://downloads.yoctoproject.org/releases/uninative";

  variants = cartesianProductOfSets {
    arch = ["x86_64" "i686"];
    cc = [true false];
  };

  buildUninative = {
    name,
    arch,
    cc,
  }:
    stdenv.mkDerivation {
      inherit name;

      src = fetchurl {
        url = "${baseURL}/${version}/${arch}-nativesdk-libc.tar.xz";
        sha256 =
          if arch == "i686"
          then "1k2zwh7jy8a65q3nxwx8pxja1ab1m3cy9vaf6k02q27h51w64a4z"
          else "00m3fad068w93ycd36fgh79jqyhpb0fji1zw65lqifz29cl5876q";
      };

      phases = ["unpackPhase" "buildPhase"];

      buildPhase = ''
        _sln() { mkdir -p "$(dirname "$2")" && [ ! -e "$2" ] && ln -sf "$1" "$2"; }
        _smv() { mkdir -p "$(dirname "$2")" && [ ! -e "$2" ] && mv "$1" "$2"; }
        find . -type d \( \
             -name 'audit' \
          -o -name '.debug' \
          -o -name 'locale' \
          -o -name 'bin' \
          -o -name 'sbin' \
          -o -name 'var' \
          -o -name 'etc' \
        \) -exec rm -fr {} +

        for dir in lib usr/lib; do
          mv $dir{,.tmp}
          _smv $dir{.tmp,/${arch}-linux-gnu}
        done

        _sln /etc usr/local/oe-sdk-hardcoded-buildpath/sysroots/${arch}-pokysdk-linux/etc
        ${
          if arch == "i686"
          then ''
            _sln /lib/i686-linux-gnu/ld-linux.so.2 lib/ld-linux.so.2
            _sln /lib usr/local/oe-sdk-hardcoded-buildpath/sysroots/${arch}-pokysdk-linux/lib
          ''
          else ''
            _sln /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
            _sln /lib64 usr/local/oe-sdk-hardcoded-buildpath/sysroots/${arch}-pokysdk-linux/lib
          ''
        }

        ${lib.optionalString (!cc) ''
          rm usr/lib/${arch}-linux-gnu/libstdc++*
          rm lib/${arch}-linux-gnu/libgcc*
        ''}

        cp -a . $out/
      '';
    };
  genMetadata = variant: let
    inherit (variant) arch cc;
    join = sep: parts: concatStringsSep sep (filter (s: s != "") parts);
  in {
    name = join "-" [
      arch
      (optionalString cc "cc")
    ];
  };
in
  listToAttrs (map (variant: let
    inherit (genMetadata variant) name;
  in
    nameValuePair name (buildUninative {
      inherit name;
      inherit (variant) arch cc;
    }))
  variants)
