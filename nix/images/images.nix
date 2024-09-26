{
  bashStatic,
  busyboxStatic,
  straceStatic,
  dockerTools,
  glibc,
  lib,
  buildPackages,
  join,
  uninative,
  buildPushContainerScript,
  mkBwrapEnv,
}: let
  inherit
    (lib)
    any
    filter
    hasSuffix
    optional
    optionals
    optionalString
    concatMapStringsSep
    removeSuffix
    ;

  genImageConfig = {
    name,
    includeAsh,
    includeBash,
    description,
  }: {
    Cmd =
      if includeAsh
      then ["/bin/sh"]
      else if includeBash
      then ["/bin/bash"]
      else [""];
    Env = optional (includeAsh || includeBash) "PATH=/bin";
    Labels = {
      "org.opencontainers.image.authors" = "r2r-dev,AleksanderGondek";
      "org.opencontainers.image.url" = "https://github.com/explore-bzl/starterkit";
      "org.opencontainers.image.title" = "starterkit-${name}";
      "org.opencontainers.image.description" = description;
    };
    Workdir = "/";
  };

  buildStarterKit = {
    name,
    includeAsh,
    includeBash,
    includeStrace,
    includeCoreutils,
    archs,
    description,
  }: let
    config = genImageConfig {inherit name includeAsh includeBash description;};
    copyToRoot =
      optionals includeAsh [busyboxStatic.minimal]
      ++ optionals includeBash [bashStatic]
      ++ optionals includeCoreutils [busyboxStatic.coreutils]
      ++ optionals includeStrace [straceStatic]
      ++ map (arch: uninative.${arch}) archs;
    ldSetupCommands = concatMapStringsSep "\n" (arch: ''
      echo /lib/${arch}-linux-gnu >> etc/ld.so.conf
      echo /usr/lib/${arch}-linux-gnu >> etc/ld.so.conf
    '') (map (removeSuffix "-cc") archs);
    extraCommands = ''
      chmod -R u+w .
      mkdir -p etc
      ${optionalString (archs != []) ldSetupCommands}
      exec ${glibc.bin}/bin/ldconfig -v -f etc/ld.so.conf -C etc/ld.so.cache -r $PWD
      chmod -R u-w .
    '';
    image = dockerTools.buildImage {
      inherit name config copyToRoot extraCommands;
      keepContentsDirlinks = true;
    };
  in
    {
      inherit image;
      push = buildPushContainerScript image;
    }
    // (
      if includeAsh
      then {bwrap = mkBwrapEnv image;}
      else {}
    );

  genMetadata = variant: rec {
    inherit (variant) includeAsh includeBash includeStrace includeCoreutils archs;
    name = join "-" [
      (optionalString includeAsh "ash")
      (optionalString includeBash "bash")
      (optionalString includeStrace "strace")
      (optionalString includeCoreutils "coreutils")
      (optionalString (archs != []) (join "-" archs))
    ];
    description = join " " [
      "Barebone container image"
      (
        optionalString
        includeAsh
        "with busybox sh"
      )
      (
        optionalString
        includeBash
        "with static bash"
      )
      (
        optionalString
        includeStrace
        "with strace"
      )
      (
        optionalString
        includeCoreutils
        "with coreutils"
      )
      (
        optionalString
        (archs != [])
        "providing glibc for ${
          join ", " (map (removeSuffix "-cc") archs)
        }"
      )
      (
        optionalString
        (any (hasSuffix "-cc") archs)
        "and libstdcxx for ${
          join ", " (map (removeSuffix "-cc") (filter (hasSuffix "-cc") archs))
        }"
      )
    ];
  };
in
  buildPackages {
    metaFun = genMetadata;
    buildFun = buildStarterKit;
    variants = {
      filter = variant:
        variant.includeAsh
        || variant.includeBash
        || variant.includeStrace
        || variant.includeCoreutils
        || variant.archs != [];
      attrs = {
        includeStrace = [false true];
        includeAsh = [false true];
        includeBash = [false true];
        includeCoreutils = [false true];
        archs = [
          []
          ["i686"]
          ["i686-cc"]
          ["x86_64"]
          ["x86_64-cc"]
          ["i686" "x86_64"]
          ["i686-cc" "x86_64"]
          ["i686" "x86_64-cc"]
          ["i686-cc" "x86_64-cc"]
        ];
      };
    };
  }
