{
  busyboxStatic,
  uninative,
  dockerTools,
  skopeo,
  writeShellScript,
  glibc,
  lib,
}: let
  buildPushContainerScript = import ./pushContainerImage.nix {
    inherit lib skopeo writeShellScript;
  };

  imageConfig = {
    title,
    description,
    includeShell,
  }: {
    Cmd =
      if includeShell
      then ["/bin/sh"]
      else [];
    Env =
      if includeShell
      then ["PATH=/bin"]
      else [];
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
        title = "starterkit-${name}";
        inherit description includeShell;
      };
      copyToRoot = lib.optional includeShell busyboxStatic ++ map (arch: uninative.${arch}) archs;
      extraCommands = let
        ldconfigScript = writeShellScript "ldconfig" ''
          exec ${glibc.bin}/bin/ldconfig -v -f etc/ld.so.conf -C etc/ld.so.cache -r $PWD
        '';
        conf =
          lib.concatMapStringsSep "\n" (arch: ''
            echo /lib/${arch}-linux-gnu >> etc/ld.so.conf
            echo /usr/lib/${arch}-linux-gnu >> etc/ld.so.conf
          '')
          archs;
      in ''
        chmod -R u+w .
        ${lib.optionalString includeShell "mkdir -p etc; echo \"root:x:0:0:root:/:/bin/sh\" > etc/passwd"}
        ${lib.optionalString (archs != []) (conf + ldconfigScript)}
        ${lib.optionalString (lib.length archs > 1) "ln -sf /usr/lib/i686-linux-gnu/locale/locale-archive usr/lib/x86_64-linux-gnu/locale/locale-archive"}
        chmod -R u-w .
      '';
    };
    push = buildPushContainerScript image;
  };

  descriptionTemplate = {
    includeShell,
    archs,
  }: let
    shellPart =
      if includeShell
      then " with a minimal shell (busybox sh)"
      else "";
    archPart =
      if archs == []
      then ""
      else " providing glibc support for ${lib.concatStringsSep ", " archs} architecture(s)";
  in "Barebone container image${shellPart}${archPart}.";
in
  lib.genAttrs [
    "empty"
    "ash"
    "ash-i686"
    "ash-x86_64"
    "ash-x86_64-i686"
    "i686"
    "x86_64"
    "x86_64-i686"
  ] (name:
    buildStarterKit rec {
      inherit name;
      includeShell = lib.hasInfix "ash" name;
      archs = lib.filter (arch: builtins.elem arch ["i686" "x86_64"]) (lib.splitString "-" name);
      description = descriptionTemplate {inherit includeShell archs;};
    })
