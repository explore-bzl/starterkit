{
  stdenv,
  skopeo,
  bubblewrap,
  umoci,
  writeShellScript,
  jq,
}: containerImageDrv: let
  rootfs = stdenv.mkDerivation {
    name = "${containerImageDrv.imageName}.rootfs";
    buildInputs = [skopeo umoci bubblewrap];

    buildCommand = ''
      skopeo copy --tmpdir=$TMPDIR --insecure-policy docker-archive:${containerImageDrv} oci:img:0

      mkdir bundle
      umoci raw unpack --rootless --image img:0 rootfs/
      mkdir rootfs/{dev,proc,tmp,root}

      mkdir -p $out
      cp -r rootfs $out/
      skopeo inspect --config --tmpdir=$TMPDIR --insecure-policy docker-archive:${containerImageDrv} > $out/config.json
    '';
  };
in
  writeShellScript "${containerImageDrv.imageName}.bwrap" ''
    cmd="$(${jq}/bin/jq -r .config.Cmd[] ${rootfs}/config.json)"
    [[ $# -gt 0 ]] && cmd="$@"
    ${bubblewrap}/bin/bwrap \
      --ro-bind ${rootfs}/rootfs / \
      --dev /dev \
      --proc /proc \
      --tmpfs /root \
      --tmpfs /tmp \
      --unshare-all \
      --clearenv \
      --setenv HOME /root \
      --chdir / \
      $cmd
  ''
