{
  images,
  filterContainerImages,
  writeTextFile,
}:
with builtins; let
  template = readFile (path {
    path = ./BUILD.template.bazel;
    name = "BUILD.template.bazel";
  });
  registryUrl = "harbor.apps.morrigna.rules-nix.build/explore-bzl";
  platformDefinitions =
    concatStringsSep "\n" (map (name: let
          image = images.${name}.image.out;
          imageUri = "docker://${registryUrl}/${name}:${image.imageTag}";
        in "
platform(
    name = \"${name}\",
    parents = [\":starterkit-x86_64-linux\"],
    exec_properties = {
        \"container-image\": \"${imageUri}\",
    },
)")
      (attrNames (filterContainerImages "image" images)));
  templated =
    replaceStrings
    ["<!-- INSERT PLATFORMS -->"]
    [platformDefinitions]
    template;
in
  writeTextFile {
    name = "BUILD.bazel";
    text = templated;
  }
