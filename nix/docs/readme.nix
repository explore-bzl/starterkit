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
    ["| Image | Description | Pull |"]
    ++ ["| --- | ---  | --- |"]
    ++ (map (name: let
      image = images.${name}.image.out;
      pullCommand = "${registryUrl}/${name}:${image.imageTag}";
      description = (fromJSON image.baseJson.text).config.Labels."org.opencontainers.image.description";
    in "| ${name} | ${description} | `${pullCommand}` |")
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
