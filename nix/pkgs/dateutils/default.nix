{
  stdenv,
  gnutar,
  zstd,
}:
stdenv.mkDerivation {
  name = "ubuntu-lunar-dateutils-amd64";
  version = "0.4.11-1_amd64";

  # Binaries built for standard linux FHS (Ubuntu)
  # that depend solely on glibc
  src = builtins.fetchurl {
    url = "http://dk.archive.ubuntu.com/ubuntu/pool/universe/d/dateutils/dateutils_0.4.11-1_amd64.deb";
    sha256 = "11sdmnw9yrc6dxrvb78vi350v6whixlzvmp164x17xn7gk9f6bh3";
  };

  nativeBuildInputs = [gnutar zstd];

  unpackPhase = ''
    ar -x $src
    tar -xf ./data.tar.zst
    mkdir -p $out/bin
    mv ./usr/bin/* $out/bin/
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  dontInstall = true;
  dontFixup = true;
}
