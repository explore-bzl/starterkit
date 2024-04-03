{
  stdenv,
  uninative-arch ? "x86_64",
}: let
  SOURCES = {
    "i686" = builtins.fetchurl {
      url = "http://downloads.yoctoproject.org/releases/uninative/4.4/i686-nativesdk-libc.tar.xz";
      sha256 = "1k2zwh7jy8a65q3nxwx8pxja1ab1m3cy9vaf6k02q27h51w64a4z";
    };
    "x86_64" = builtins.fetchurl {
      url = "http://downloads.yoctoproject.org/releases/uninative/4.4/x86_64-nativesdk-libc.tar.xz";
      sha256 = "00m3fad068w93ycd36fgh79jqyhpb0fji1zw65lqifz29cl5876q";
    };
  };
in
  stdenv.mkDerivation {
    name = "yocto-uninative-4.4-${uninative-arch}-sysroot";

    src = builtins.getAttr uninative-arch SOURCES;

    buildPhase = ''
      # Remove audit and debug dirs
      rm -rf $(find . -type d -name 'audit')
      rm -rf $(find . -name '.debug')
      rm -rf usr/bin sbin var etc/ld.so.*

      mkdir -p etc lib lib64 usr/lib

      mv lib lib.tmp
      mkdir lib
      mv lib.tmp lib/${uninative-arch}-linux-gnu

      mv usr/lib usr/lib.tmp
      mkdir usr/lib
      mv usr/lib.tmp usr/lib/${uninative-arch}-linux-gnu

      mkdir -p usr/local/oe-sdk-hardcoded-buildpath/sysroots/${uninative-arch}-pokysdk-linux
      ln -sf /lib usr/local/oe-sdk-hardcoded-buildpath/sysroots/${uninative-arch}-pokysdk-linux/lib
      ln -sf /etc usr/local/oe-sdk-hardcoded-buildpath/sysroots/${uninative-arch}-pokysdk-linux/etc

      # Create ld-linux symlink based on architecture
      if [ "${uninative-arch}" = "i686" ]; then
          ln -sf /lib/i686-linux-gnu/ld-linux.so.2 lib/ld-linux.so.2
      elif [ "${uninative-arch}" = "x86_64" ]; then
          ln -sf /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
      fi

      mkdir -p $out
      cp -R ./ $out/
    '';
  }
