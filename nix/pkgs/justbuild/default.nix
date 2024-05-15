{stdenv}:
stdenv.mkDerivation {
  name = "justbuild";
  version = "1.3.0";

  src = builtins.fetchTarball {
    url = "https://github.com/oreiche/justbuild/releases/download/v1.3.0/justbuild-1.3.0-x86_64-linux.tar.gz";
    sha256 = "1s8r5s8yy936zn81lp6mpbx8xmw288pkqfc9i7h4r91dfg9qlaga";
  };

  phases = ["unpackPhase" "installPhase"];
  installPhase = "mkdir $out && mv * $out";
}
