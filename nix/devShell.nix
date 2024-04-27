{
  lib,
  mkShell,
  alejandra,
  cacert,
  cocogitto,
  git,
  helix,
  niv,
  statix,
  deadnix,
  mdsh,
} @ args: let
  packages = lib.attrsets.attrValues (
    builtins.removeAttrs args ["mkShell" "lib"]
  );
in
  mkShell {
    inherit packages;
    name = "starterkit-shell";
  }
