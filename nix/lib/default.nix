{lib}: let
  inherit
    (lib)
    cartesianProductOfSets
    concatStringsSep
    nameValuePair
    listToAttrs
    ;
  filterContainerImages = attr: containerImages: lib.filterAttrs (_: v: v ? ${attr}) containerImages;
in {
  inherit filterContainerImages;
  join = sep: parts: concatStringsSep sep (builtins.filter (s: s != "") parts);

  buildPackages = {
    metaFun,
    buildFun,
    variants,
  }: let
    genVariants = {
      filter ? null,
      attrs,
    }:
      if builtins.isNull filter
      then (cartesianProductOfSets attrs)
      else builtins.filter filter (cartesianProductOfSets attrs);
  in
    listToAttrs (map (variant: let
      meta = metaFun variant;
    in
      nameValuePair meta.name (buildFun (meta // variant)))
    (genVariants variants));

  concatContainerCommands = attr: containerImages: suffix:
    lib.concatMapStringsSep "\n" (v: "${v.${attr}}${suffix}") (lib.attrValues (filterContainerImages attr containerImages));
}
