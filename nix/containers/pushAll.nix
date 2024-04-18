{
  lib,
  writeShellScript,
  containerImages,
}: let
  buildPushAllContainerImagesScript = containerImages:
    writeShellScript "pushAllContainerImages.sh" ''
      set -euo pipefail

      destRegistry=$1
      destUsername=$2
      destPass=$3

      ${
        (
          builtins.foldl'
          (acc: current: acc + "${current} $destRegistry $destUsername $destPass\n")
          ""
          (lib.mapAttrsToList (_: v: builtins.getAttr "push" v) (lib.filterAttrs (_: val: builtins.isAttrs val && (builtins.hasAttr "image" val)) containerImages))
        )
      }
    '';
in
  buildPushAllContainerImagesScript containerImages
