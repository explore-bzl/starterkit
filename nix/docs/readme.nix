{
  images,
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
          tag = images.${name}.image.out.imageTag;
          pullCommand = "${registryUrl}/${name}:${tag}";
        in "| ${name} | \`${pullCommand}\` |")
        (builtins.filter (name: name != "override" && name != "overrideDerivation" && name != "all" && name != "test")
          (builtins.attrNames images)))
    );
  templated =
    builtins.replaceStrings
    ["<!-- INSERT TABLE -->" "<!-- INSERT EXAMPLE IMAGE NAME -->" "<!-- INSERT EXAMPLE IMAGE TAG -->"]
    [markdownTableWithContainers images.ash-x86_64-cc.image.imageName images.ash-x86_64-cc.image.imageTag]
    template;
in
  writeTextFile {
    name = "README.md";
    text = templated;
  }
