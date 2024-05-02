{
  images,
  filterContainerImages,
  writeTextFile,
}:
with builtins; let
  template = readFile (path {
    path = ./README.template.md;
    name = "README.template.md";
  });
  registryUrl = "harbor.apps.morrigna.rules-nix.build/explore-bzl";
  markdownTableWithContainers = concatStringsSep "\n" (
    ["| Image | Pull |"]
    ++ ["| ---   | ---  |"]
    ++ (map (name: let
      tag = images.${name}.image.out.imageTag;
      pullCommand = "${registryUrl}/${name}:${tag}";
    in "| ${name} | `${pullCommand}` |")
    (attrNames (filterContainerImages "image" images)))
  );
  templated =
    replaceStrings
    ["<!-- INSERT TABLE -->" "<!-- INSERT EXAMPLE IMAGE NAME -->" "<!-- INSERT EXAMPLE IMAGE TAG -->"]
    [markdownTableWithContainers images.ash-x86_64-cc.image.imageName images.ash-x86_64-cc.image.imageTag]
    template;
in
  writeTextFile {
    name = "README.md";
    text = templated;
  }
