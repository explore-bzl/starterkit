{
  stdenv,
  pkgsStatic,
}:
stdenv.mkDerivation {
  name = "bash-static-hardcopy";

  phases = ["buildPhase"];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${pkgsStatic.bash}/bin/bash $out/bin/bash
  '';
}
