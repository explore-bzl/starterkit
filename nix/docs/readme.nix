{
  containerImages,
  writeTextFile,
}: let
  template = builtins.readFile (builtins.path {
    path = ./README.template.md;
    name = "README.template.md";
  });
  registryUrl = "harbor.apps.morrigna.rules-nix.build/explore-bzl";
  markdownTableWithContainers =
    "| Image | Pull |\n| ---   | ---  |\n"
    + (
      builtins.concatStringsSep "\n" (map (name: let
          tag = containerImages.${name}.image.out.imageTag;
          pullCommand = "${registryUrl}/${name}:${tag}";
        in "| ${name} | \`${pullCommand}\` |")
        (builtins.filter (name: name != "override" && name != "overrideDerivation")
          (builtins.attrNames containerImages)))
    );
  templated =
    builtins.replaceStrings
    ["<!-- INSERT TABLE -->" "<!-- INSERT EXAMPLE IMAGE NAME -->" "<!-- INSERT EXAMPLE IMAGE TAG -->"]
    [markdownTableWithContainers containerImages.ash-x86_64-cc.image.imageName containerImages.ash-x86_64-cc.image.imageTag]
    template;
in
  writeTextFile {
    name = "README.md";
    text = templated;
  }
