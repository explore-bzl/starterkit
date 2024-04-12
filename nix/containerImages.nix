{
  busyboxStatic,
  uninative,
  dockerTools,
  skopeo,
  writeShellScript,
  glibc,
  lib,
}: let
  ldCache = archs: let
    ldconfig = writeShellScript "ldconfig" ''
      exec ${glibc.bin}/bin/ldconfig -v -f etc/ld.so.conf -C etc/ld.so.cache -r $PWD
    '';
    conf =
      lib.concatMapStringsSep "\n" (x: ''
        echo /lib/${x}-linux-gnu >> etc/ld.so.conf
        echo /usr/lib/${x}-linux-gnu >> etc/ld.so.conf
      '')
      archs;
  in ''
    ${conf}
    ${ldconfig}
  '';

  buildPushContainerScript = import ./pushContainerImage.nix {
    inherit lib skopeo writeShellScript;
  };

  extraCommands = commands: ''
    chmod u+w -R etc lib usr
    ${lib.concatStringsSep "\n" commands}
    chmod u-w -R etc lib usr
  '';

  imageConfig = {
    title,
    description,
  }: {
    Cmd = ["/bin/sh"];
    Label = lib.strings.concatStrings (lib.strings.intersperse " " [
      "org.opencontainers.image.authors=\"r2r-dev,AleksanderGondek\""
      "org.opencontainers.image.url=\"https://github.com/explore-bzl/starterkit\""
      "org.opencontainers.image.title=\"${title}\""
      "org.opencontainers.image.description=\"${description}\""
    ]);
    Workdir = "/";
  };

  buildStarterKit = name: archs: rec {
    image = dockerTools.buildImage {
      inherit name;
      fromImage = ashOnly.image;
      keepContentsDirlinks = true;
      config = imageConfig {
        title = name;
        description = "Barebone image containing only busybox sh and glibc.";
      };
      copyToRoot = map (x: lib.getAttr x uninative) archs;
      extraCommands = extraCommands ([
          (ldCache archs)
        ]
        ++ lib.optional (lib.length archs > 1) ''
          ln -sf /usr/lib/i686-linux-gnu/locale/locale-archive \
                 usr/lib/x86_64-linux-gnu/locale/locale-archive
        '');
    };
    push = buildPushContainerScript image;
  };

  ashOnly = rec {
    image = dockerTools.buildImage {
      name = "starterkit-ash";
      config = imageConfig {
        title = "starterkit-ash";
        description = "Barebone image containing only busybox sh.";
      };
      copyToRoot = [busyboxStatic];
      extraCommands = ''
        mkdir etc
        echo "root:x:0:0:root:/:/bin/sh" > etc/passwd
        chmod u-w -R bin etc
      '';
    };
    push = buildPushContainerScript image;
  };
in {
  inherit ashOnly;
  starterKit-i686 = buildStarterKit "starterkit-i686" ["i686"];
  starterKit-x86_64 = buildStarterKit "starterkit-x86_64" ["x86_64"];
  starterKit-x86_64-i686 = buildStarterKit "starterkit-x86_64-i686" ["x86_64" "i686"];
}
