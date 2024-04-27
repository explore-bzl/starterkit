{
  lib,
  writeShellScript,
  testContainerImages,
}: let
  buildTestsScript = testContainerImages:
    writeShellScript "tests.sh" ''
      set -euo pipefail

      echo "[starterkit] execution of test images started.."
      ${
        (
          builtins.foldl'
          (acc: current: acc + "${current}\n")
          ""
          (lib.mapAttrsToList (_: v: builtins.getAttr "bwrap" v) (lib.filterAttrs (_: val: builtins.isAttrs val && (builtins.hasAttr "image" val)) testContainerImages))
        )
      }
      echo "[starterkit] execution of test images finished successfully!"
    '';
in
  buildTestsScript testContainerImages
