{
  busyboxStatic,
  dockerTools,
  glibc,
  lib,
  uninative,
  buildPushContainerScript,
}: let
  inherit
    (lib)
    cartesianProductOfSets
    concatMapStringsSep
    concatStringsSep
    filter
    nameValuePair
    listToAttrs
    optional
    optionals
    optionalString
    removeSuffix
    ;

  imageConfig = {
    title,
    description,
    includeShell,
  }: {
    Cmd = optional includeShell "/bin/sh";
    Env = optional includeShell "PATH=/bin";
    Labels = {
      "org.opencontainers.image.authors" = "r2r-dev,AleksanderGondek";
      "org.opencontainers.image.url" = "https://github.com/explore-bzl/starterkit";
      "org.opencontainers.image.title" = title;
      "org.opencontainers.image.description" = description;
    };
    Workdir = "/";
  };

  buildStarterKit = {
    name,
    includeShell,
    archs,
    description,
  }: rec {
    image = dockerTools.buildImage {
      inherit name;
      keepContentsDirlinks = true;
      config = imageConfig {
        inherit description includeShell;
        title = "starterkit-${name}";
      };
      copyToRoot = optionals includeShell [busyboxStatic] ++ map (arch: uninative.${arch}) archs;
      extraCommands = let
        ldSetup = optionalString (archs != []) ''
          ${concatMapStringsSep "\n" (arch: ''
            echo /lib/${arch}-linux-gnu >> etc/ld.so.conf
            echo /usr/lib/${arch}-linux-gnu >> etc/ld.so.conf
          '') (map (removeSuffix "-cc") archs)}
          exec ${glibc.bin}/bin/ldconfig -v -f etc/ld.so.conf -C etc/ld.so.cache -r $PWD
        '';
      in ''
        chmod -R u+w .
        mkdir -p etc
        ${ldSetup}
        chmod -R u-w .
      '';
    };
    push = buildPushContainerScript image;
  };

  variants = cartesianProductOfSets {
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

  genMetadata = variant: let
    inherit (variant) includeShell archs;
    join = sep: parts: concatStringsSep sep (filter (s: s != "") parts);
  in {
    name = join "-" [
      (optionalString includeShell "ash")
      (optionalString (archs != []) (concatStringsSep "-" archs))
    ];
    description = join " " [
      "Barebone container image"
      (optionalString includeShell "with a minimal shell (busybox sh)")
      (optionalString (archs != []) "providing glibc support for ${concatStringsSep " " archs} architecture(s)")
    ];
  };
in
  listToAttrs (map (variant: let
    inherit (genMetadata variant) name description;
  in
    nameValuePair name (buildStarterKit {
      inherit name description;
      inherit (variant) includeShell archs;
    }))
  variants)
