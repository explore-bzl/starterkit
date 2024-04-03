{
  busyboxStatic,
  uninative,
  dockerTools,
  writeShellScript,
  glibc,
  lib,
}: let
  inherit (builtins) concatStringsSep getAttr;
  inherit (lib.lists) forEach;
  concatNewline = x: concatStringsSep "\n" x;

  ldCache = archs: let
    ldconfig = writeShellScript "ldconfig" ''
      exec ${glibc.bin}/bin/ldconfig -v -f etc/ld.so.conf -C etc/ld.so.cache -r $(pwd)
    '';
    conf = concatNewline (
      forEach archs (
        x:
          concatNewline [
            "echo /lib/${x}-linux-gnu >> etc/ld.so.conf"
            "echo /usr/lib/${x}-linux-gnu >> etc/ld.so.conf"
          ]
      )
    );
  in ''
    ${conf}
    ${ldconfig}
  '';

  extraCommands = commands: ''
    chmod u+w -R etc lib usr
    ${concatNewline commands}
    chmod u-w -R etc lib usr
  '';

  ashOnly = dockerTools.buildImage {
    name = "starterkit-ash";
    copyToRoot = busyboxStatic;
    extraCommands = ''
      # Add root user
      mkdir etc
      echo "root:x:0:0:root:/:/bin/sh" > etc/passwd
      chmod u-w -R bin etc
    '';
  };
  starterKit-i686 = dockerTools.buildImage {
    name = "starterkit-i686";
    fromImage = ashOnly;
    keepContentsDirlinks = true;
    copyToRoot = getAttr "i686" uninative;
    extraCommands = extraCommands [
      (ldCache ["i686"])
    ];
  };
  starterKit-x86_64 = dockerTools.buildImage {
    name = "starterkit-x86_64";
    fromImage = ashOnly;
    keepContentsDirlinks = true;
    copyToRoot = getAttr "x86_64" uninative;
    extraCommands = extraCommands [
      (ldCache ["x86_64"])
    ];
  };
  starterKit-x86_64-i686 = dockerTools.buildImage {
    name = "starterkit-x86_64-i686";
    fromImage = ashOnly;
    keepContentsDirlinks = true;
    copyToRoot = [
      (getAttr "x86_64" uninative)
      (getAttr "i686" uninative)
    ];
    extraCommands = extraCommands [
      ''
        ln -sf /usr/lib/i686-linux-gnu/locale/locale-archive \
               usr/lib/x86_64-linux-gnu/locale/locale-archive
      ''
      (ldCache ["x86_64" "i686"])
    ];
  };
in {
  inherit ashOnly starterKit-i686 starterKit-x86_64 starterKit-x86_64-i686;
}
