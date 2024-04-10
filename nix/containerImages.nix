{
  busyboxStatic,
  uninative,
  dockerTools,
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

  extraCommands = commands: ''
    chmod u+w -R etc lib usr
    ${lib.concatStringsSep "\n" commands}
    chmod u-w -R etc lib usr
  '';

  buildStarterKit = name: archs:
    dockerTools.buildImage {
      inherit name;
      fromImage = ashOnly;
      keepContentsDirlinks = true;
      copyToRoot = map (x: lib.getAttr x uninative) archs;
      extraCommands = extraCommands ([
          (ldCache archs)
        ]
        ++ lib.optional (lib.length archs > 1) ''
          ln -sf /usr/lib/i686-linux-gnu/locale/locale-archive \
                 usr/lib/x86_64-linux-gnu/locale/locale-archive
        '');
    };

  ashOnly = dockerTools.buildImage {
    name = "starterkit-ash";
    copyToRoot = [busyboxStatic];
    extraCommands = ''
      mkdir etc
      echo "root:x:0:0:root:/:/bin/sh" > etc/passwd
      chmod u-w -R bin etc
    '';
  };
in {
  inherit ashOnly;
  starterKit-i686 = buildStarterKit "starterkit-i686" ["i686"];
  starterKit-x86_64 = buildStarterKit "starterkit-x86_64" ["x86_64"];
  starterKit-x86_64-i686 = buildStarterKit "starterkit-x86_64-i686" ["x86_64" "i686"];
}
