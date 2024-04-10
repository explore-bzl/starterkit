{
  stdenv,
  uninative-arch ? "x86_64",
}: let
  pname = "yocto-uninative";
  version = "4.4";
  baseURL = "http://downloads.yoctoproject.org/releases/uninative";

  src = builtins.fetchurl {
    url = "${baseURL}/${version}/${uninative-arch}-nativesdk-libc.tar.xz";
    sha256 =
      if uninative-arch == "i686"
      then "1k2zwh7jy8a65q3nxwx8pxja1ab1m3cy9vaf6k02q27h51w64a4z"
      else "00m3fad068w93ycd36fgh79jqyhpb0fji1zw65lqifz29cl5876q";
  };
in
  stdenv.mkDerivation {
    inherit pname version src;
    name = "${pname}-${version}-${uninative-arch}-sysroot";

    phases = ["unpackPhase" "buildPhase"];

    buildPhase = ''
      _sln() { mkdir -p "$(dirname "$2")" && [ ! -e "$2" ] && ln -sf "$1" "$2"; }
      _smv() { mkdir -p "$(dirname "$2")" && [ ! -e "$2" ] && mv "$1" "$2"; }

      find . -type d -name 'audit' -o -name '.debug' | xargs rm -rf
      rm -rf usr/bin sbin var etc/ld.so.*

      for dir in lib usr/lib; do
        mv $dir{,.tmp}
        _smv $dir{.tmp,/${uninative-arch}-linux-gnu}
      done

      for link in lib etc; do
        _sln /''${link} usr/local/oe-sdk-hardcoded-buildpath/sysroots/${uninative-arch}-pokysdk-linux/$link
      done

      if [ "${uninative-arch}" = "i686" ]; then
          _sln /lib/i686-linux-gnu/ld-linux.so.2 lib/ld-linux.so.2
      elif [ "${uninative-arch}" = "x86_64" ]; then
          _sln /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
      fi

      cp -a . $out/
    '';
  }
