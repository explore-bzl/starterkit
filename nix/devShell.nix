{
  mkShell,
  alejandra,
  cocogitto,
  git,
  helix,
  niv,
  statix,
  deadnix,
  mdsh,
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
    mdsh
  ];
}
