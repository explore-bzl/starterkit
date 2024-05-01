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

      mkdir -p $out
      cp -r rootfs $out/
      skopeo inspect --config --tmpdir=$TMPDIR --insecure-policy docker-archive:${containerImageDrv} > $out/config.json
    '';
  };
in
  writeShellScript "${containerImageDrv.imageName}.bwrap" ''
    ${bubblewrap}/bin/bwrap \
      --ro-bind ${rootfs}/rootfs / \
      --unshare-all \
      --chdir / \
      $(${jq}/bin/jq -r .config.Cmd[] ${rootfs}/config.json)
  ''
