{
  mkShell,
  alejandra,
  cocogitto,
  git,
  helix,
  niv,
  statix,
  deadnix,
}:
mkShell {
  name = "starterkit-shell";
  packages = [
    alejandra
    cocogitto
    git
    helix
    niv
    statix
    deadnix
  ];
}
