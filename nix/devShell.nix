{
  mkShell,
  alejandra,
  cocogitto,
  git,
  helix,
  niv,
  statix,
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
  ];
}
