{
  busyboxStatic,
  dockerTools,
  glibc,
  lib,
  buildPackages,
  join,
  uninative,
  buildPushContainerScript,
  mkBwrapEnv,
}: let
  inherit (lib) optional optionals optionalString concatMapStringsSep removeSuffix;

  genImageConfig = {
    name,
    includeShell,
    description,
  }: {
    Cmd = optional includeShell "/bin/sh";
    Env = optional includeShell "PATH=/bin";
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
    includeShell,
    archs,
    description,
  }: let
    config = genImageConfig {inherit name includeShell description;};
    copyToRoot = optionals includeShell [busyboxStatic] ++ map (arch: uninative.${arch}) archs;
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
      if includeShell
      then {bwrap = mkBwrapEnv image;}
      else {}
    );

  genMetadata = variant: rec {
    inherit (variant) includeShell archs;
    name = join "-" [
      (optionalString includeShell "ash")
      (optionalString (archs != []) (join "-" archs))
    ];
    description = join " " [
      "Barebone container image"
      (optionalString includeShell "with a minimal shell (busybox sh)")
      (optionalString (archs != []) "providing glibc support for ${join " " archs} architecture(s)")
    ];
  };
in
  buildPackages {
    metaFun = genMetadata;
    buildFun = buildStarterKit;
    variants = {
      filter = variant: variant.includeShell || variant.archs != [];
      attrs = {
        includeShell = [false true];
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
