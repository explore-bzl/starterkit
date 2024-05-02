{
  writeShellScript,
  containerImages,
  concatContainerCommands,
}:
writeShellScript "pushAllContainerImages.sh" ''
  set -euo pipefail

  ${concatContainerCommands "push" containerImages " $@"}
''
