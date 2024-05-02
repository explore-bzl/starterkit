{
  writeShellScript,
  testContainerImages,
  concatContainerCommands,
}:
writeShellScript "tests.sh" ''
  set -euo pipefail

  echo "[starterkit] execution of test images started.."
  ${concatContainerCommands "bwrap" testContainerImages ""}
  echo "[starterkit] execution of test images finished successfully!"
''
