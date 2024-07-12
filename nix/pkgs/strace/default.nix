{
  stdenv,
  pkgsStatic,
}:
stdenv.mkDerivation {
  name = "strace-static-hardcopy";

  phases = ["buildPhase"];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${pkgsStatic.strace}/bin/strace $out/bin/strace
  '';
}
