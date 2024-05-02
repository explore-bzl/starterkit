{
  skopeo,
  writeShellScript,
}: containerImageDrv:
writeShellScript "${containerImageDrv.imageName}.push" ''
  set -euo pipefail

  destRegistry=$1
  destUsername=$2
  destPass=$3

  ${skopeo}/bin/skopeo \
    --insecure-policy \
    copy \
    --dest-username $destUsername \
    --dest-password $destPass \
    docker-archive:${containerImageDrv}:${containerImageDrv.imageName}:${containerImageDrv.imageTag} \
    docker://$destRegistry/${containerImageDrv.imageName}:${containerImageDrv.imageTag}
''
