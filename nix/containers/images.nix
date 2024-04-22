{
  busyboxStatic,
  dockerTools,
  glibc,
  lib,
  skopeo,
  uninative,
  writeShellScript,
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

  buildPushContainerScript = import ./push.nix {
    inherit lib skopeo writeShellScript;
  };

  imageConfig = {
    title,
    description,
    includeShell,
    rootUser,
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
    User =
      if rootUser
      then "root"
      else "nonroot";
  };

  buildStarterKit = {
    name,
    includeShell,
    archs,
    rootUser,
    description,
  }: rec {
    image = dockerTools.buildImage {
      inherit name;
      keepContentsDirlinks = true;
      config = imageConfig {
        inherit description includeShell rootUser;
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
        userSetup = let
          inherit
            (
              (
                if rootUser
                then {
                  user = "root";
                  uid = "0";
                }
                else {
                  user = "nonroot";
                  uid = "65532";
                }
              )
              // (
                if includeShell
                then {shell = "/bin/sh";}
                else {shell = "/dev/null";}
              )
            )
            user
            uid
            shell
            ;
        in ''
          echo "${user}:x:${uid}:${user}" > etc/group
          echo "${user}:x:${uid}:${uid}::/:${shell}" > etc/passwd
        '';
      in ''
        chmod -R u+w .
        mkdir -p etc
        ${userSetup}
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
    rootUser = [false true];
  };

  genMetadata = variant: let
    inherit (variant) includeShell archs rootUser;
    join = sep: parts: concatStringsSep sep (filter (s: s != "") parts);
  in {
    name = join "-" [
      (optionalString includeShell "ash")
      (optionalString (archs != []) (concatStringsSep "-" archs))
      (optionalString rootUser "root")
    ];
    description = join " " [
      "Barebone container image"
      (optionalString includeShell "with a minimal shell (busybox sh)")
      (optionalString (archs != []) "providing glibc support for ${concatStringsSep " " archs} architecture(s)")
      (optionalString rootUser "as root" + optionalString (!rootUser) "as non-root")
    ];
  };
in
  listToAttrs (map (variant: let
    inherit (genMetadata variant) name description;
  in
    nameValuePair name (buildStarterKit {
      inherit name description;
      inherit (variant) includeShell archs rootUser;
    }))
  variants)
