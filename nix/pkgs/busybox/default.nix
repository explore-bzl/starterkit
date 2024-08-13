{
  busybox,
  buildPackages,
  join,
  lib,
  removeReferencesTo,
}: let
  buildBusybox = {
    name,
    config,
    isMinimal ? (config == "minimal"),
  }:
    (busybox.overrideAttrs (_: {
      nativeBuildInputs = [removeReferencesTo];
      installPhase = ''
        remove-references-to -t $out busybox
        mkdir -p $out/bin
        cp busybox $out/bin/busybox
        ${
          if isMinimal
          then ''
            ln -sf busybox $out/bin/sh
          ''
          else ''
            $out/bin/busybox --install -s $out/bin
          ''
        }'';
    }))
    .override {
      enableStatic = true;
      enableMinimal = isMinimal;
      useMusl = true;
    }
    // (
      if isMinimal
      then {
        extraConfig = ''
          CONFIG_FEATURE_FANCY_ECHO y
          CONFIG_FEATURE_SH_MATH y
          CONFIG_FEATURE_SH_MATH_64 y
          CONFIG_FEATURE_TEST_64 y

          CONFIG_ASH y
          CONFIG_ASH_OPTIMIZE_FOR_SIZE y

          CONFIG_ASH_ALIAS y
          CONFIG_ASH_BASH_COMPAT y
          CONFIG_ASH_CMDCMD y
          CONFIG_ASH_ECHO y
          CONFIG_ASH_GETOPTS y
          CONFIG_ASH_INTERNAL_GLOB y
          CONFIG_ASH_JOB_CONTROL y
          CONFIG_ASH_PRINTF y
          CONFIG_ASH_TEST y
        '';
      }
      else {}
    );
  genMetadata = variant: rec {
    inherit (variant) config;
    name = join "-" [config];
  };
in
  buildPackages {
    metaFun = genMetadata;
    buildFun = buildBusybox;
    variants = {
      attrs = {
        config = ["minimal" "coreutils"];
      };
    };
  }
